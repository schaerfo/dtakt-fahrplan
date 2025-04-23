# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

import json
import sqlite3
import sys

import pandas as pd


def main():
    with open(sys.argv[2]) as f:
        osm_locations = json.load(f)
    osm_locations_df = pd.json_normalize(osm_locations['elements'])
    osm_locations_df.rename(columns={
        "tags.uic_ref": "EVA_NR",
        "tags.name": "name_db",
        "tags.operator": "Betreiber_Name",
        "tags.ds100": "DS100",
    }, inplace=True)
    osm_locations_df.set_index("DS100", inplace=True)
    osm_locations_df = osm_locations_df.loc[~osm_locations_df.index.duplicated(), :]
    # De-fragment the data frame
    osm_locations_df = osm_locations_df.copy()
    osm_locations_df["Laenge"] = pd.to_numeric(osm_locations_df["tags.lon"])
    osm_locations_df["Breite"] = pd.to_numeric(osm_locations_df["tags.lat"])
    station_location_df = osm_locations_df[["EVA_NR", "name_db", "Betreiber_Name", "Laenge", "Breite"]]
    with sqlite3.connect(sys.argv[1]) as conn:
        station_location_df.to_sql("station_location", conn, index=True, if_exists='append')


if __name__ == '__main__':
    main()
