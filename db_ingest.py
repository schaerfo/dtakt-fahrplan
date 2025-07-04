# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

from pathlib import Path
import re
import sys
from typing import List
import xml.etree.ElementTree as ET

from sqlalchemy import create_engine
from sqlalchemy import ForeignKey
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column
from sqlalchemy.orm import relationship
from sqlalchemy.orm import Session

NAMESPACE = "{http://www.railml.org/schemas/2013}"


class Base(DeclarativeBase):
    pass


class Station(Base):
    __tablename__ = "station"

    station_id: Mapped[str] = mapped_column(primary_key=True)
    name: Mapped[str]
    operational_type: Mapped[str | None]


class Category(Base):
    __tablename__ = "category"

    category_id: Mapped[str] = mapped_column(primary_key=True)
    code: Mapped[str]
    description: Mapped[str]


class TrainPart(Base):
    __tablename__ = "train_part"

    train_part_id: Mapped[str] = mapped_column(primary_key=True)
    category_id: Mapped[int] = mapped_column(ForeignKey("category.category_id"))

    category: Mapped[Category] = relationship()
    train: Mapped["Train"] = relationship(back_populates="train_part")


class Stop(Base):
    __tablename__ = "stop"

    stop_id: Mapped[int] = mapped_column(primary_key=True)
    train_part_id: Mapped[int] = mapped_column(ForeignKey("train_part.train_part_id"))
    station_id: Mapped[int] = mapped_column(ForeignKey("station.station_id"))
    arrival: Mapped[str | None]
    departure: Mapped[str | None]
    sequence: Mapped[int]

    train_part: Mapped[TrainPart] = relationship()
    station: Mapped[Station] = relationship()


class Train(Base):
    __tablename__ = "train"

    train_id: Mapped[str] = mapped_column(primary_key=True)
    description: Mapped[str]
    train_number: Mapped[str | None]
    line_name: Mapped[str | None]
    train_part_id: Mapped[int] = mapped_column(ForeignKey("train_part.train_part_id"))
    group_id: Mapped[int] = mapped_column(ForeignKey("train_group.train_group_id"))
    sequence: Mapped[int]

    train_part: Mapped[TrainPart] = relationship(back_populates="train")


class TrainGroup(Base):
    __tablename__ = "train_group"

    train_group_id: Mapped[str] = mapped_column(primary_key=True)
    code: Mapped[str]
    train_number = Mapped[int]

    trains: Mapped[List[Train]] = relationship()


class TimeExtractor:
    _time_regex = re.compile(r"^((\d{2}):\d{2}:\d{2})(?:\.\d+)?$")

    def __init__(self):
        self._day_offset = 0

    # In some cases, there is a negative (departure|arrival)Day. Since GTFS does not allow negative times,
    # we have to increase all times by an appropriate amount for the affected run
    def extract_time(self, curr_times, key):
        result = curr_times.attrib.get(key)
        if result:
            m = self._time_regex.search(result)
            result = m[1]
            day = curr_times.attrib.get(key + 'Day')
            if day:
                day = int(day)
                if day < 0:
                    self._day_offset = -day
                day += self._day_offset
            else:
                day = self._day_offset
            if day > 0:
                hours = m[2]
                corrected_hours = int(hours) + 24 * day
                result = str(corrected_hours) + result[len(hours):]
        return result


def main():
    db_filename = sys.argv[2]
    Path(db_filename).unlink(missing_ok=True)

    engine = create_engine(f"sqlite:///{db_filename}")
    Base.metadata.create_all(engine)

    tree = ET.parse(sys.argv[1])
    root = tree.getroot()
    ocps = root.find(f"{NAMESPACE}infrastructure").find(f"{NAMESPACE}operationControlPoints")
    stations = dict()
    for curr_ocp in ocps:
        prop = curr_ocp.find(f"{NAMESPACE}propOperational")
        name = curr_ocp.attrib['name']
        ocp_id = curr_ocp.attrib['id']
        code = curr_ocp.attrib['code']
        op_type = None
        if prop is not None:
            op_type = prop.attrib['operationalType']
        #if op_type == "blockSignal":
        #    continue
        stations[ocp_id] = Station(
            station_id=ocp_id,
            name=name,
            operational_type=op_type,
        )

    tt = root.find(f"{NAMESPACE}timetable")
    categories_tag = tt.find(f"{NAMESPACE}categories")
    categories = {}
    for curr_category in categories_tag:
        cat_id = curr_category.attrib['id']
        cat_code = curr_category.attrib['code']
        cat_descr = curr_category.attrib['description']
        categories[cat_id] = Category(
            category_id=cat_id,
            code=cat_code,
            description=cat_descr,
        )

    train_parts_tag = tt.find(f"{NAMESPACE}trainParts")
    train_parts = {}
    stops = []
    for curr_train_part in train_parts_tag:
        extractor = TimeExtractor()
        train_part_id = curr_train_part.attrib['id']
        train_part = TrainPart(
            train_part_id=train_part_id,
            category=categories[curr_train_part.attrib['categoryRef']],
        )
        train_parts[train_part_id] = train_part
        ocps_tag = curr_train_part.find(f"{NAMESPACE}ocpsTT")
        stop_sequence = 1
        for curr_ocp in ocps_tag:
            if curr_ocp.attrib['ocpType'] == 'pass':
                continue
            sequence = int(curr_ocp.attrib["sequence"])
            if curr_ocp.attrib['ocpType'] != 'stop':
                print(f"ocp {sequence} of train part {train_part_id} has type {curr_ocp.attrib['ocpType']}")
                continue
            arrival = None
            departure = None
            for curr_times in curr_ocp.iterfind(f"{NAMESPACE}times"):
                if curr_times.attrib['scope'] == 'published':
                    arrival = extractor.extract_time(curr_times, 'arrival')
                    departure = extractor.extract_time(curr_times, 'departure')
            station = stations[curr_ocp.attrib['ocpRef']]
            stops.append(Stop(
                train_part=train_part,
                station=station,
                sequence=stop_sequence,
                arrival=arrival,
                departure=departure,
            ))
            stop_sequence += 1

    trains_tag = tt.find(f"{NAMESPACE}trains")
    trains = {}
    for curr_train in trains_tag:
        train_part_id = curr_train.find(f"{NAMESPACE}trainPartSequence").find(f"{NAMESPACE}trainPartRef").attrib['ref']
        train_id = curr_train.attrib["id"]
        train_descr = curr_train.attrib["description"]
        train_num = None
        if "trainNumber" in curr_train.attrib:
            train_num = curr_train.attrib["trainNumber"]
        line_name_tag = curr_train.find("{http://www.sma-partner.ch/schemas/2013/Viriato/Base}trainName")
        line_name = None
        if line_name_tag is not None:
            line_name = line_name_tag.text
        trains[train_id] = Train(
            train_id=train_id,
            description=train_descr,
            train_number=train_num,
            line_name=line_name,
            train_part=train_parts[train_part_id],
        )

    train_groups_tag = tt.find(f"{NAMESPACE}trainGroups")
    train_groups = []
    for curr_train_group in train_groups_tag:
        train_group_id = curr_train_group.attrib['id']
        code = curr_train_group.attrib['code']
        train_num = int(curr_train_group.attrib['trainNumber'])
        member_trains = []
        for child in curr_train_group:
            if child.tag != f"{NAMESPACE}trainRef":
                print(f"non train ref {child.tag} in group {train_group_id}")
                continue
            train_ref = child.attrib['ref']
            trains[train_ref].sequence = child.attrib['sequence']
            member_trains.append(trains[train_ref])
        train_groups.append(TrainGroup(
            train_group_id=train_group_id,
            code=code,
            train_number=train_num,
            trains=member_trains,
        ))

    with Session(engine) as session:
        session.add_all(stations.values())
        session.add_all(categories.values())
        session.add_all(train_parts.values())
        session.add_all(stops)
        session.add_all(trains.values())
        session.add_all(train_groups)
        session.commit()


if __name__ == '__main__':
    main()
