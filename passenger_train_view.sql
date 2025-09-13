-- Copyright 2025 Christian Schärf
-- SPDX-License-Identifier: MIT

CREATE VIEW "train_with_part" AS
  select
    train.train_id,
    train.description,
    train.train_number,
    train.line_name,
    train.group_id,
    train_part.train_part_id as train_part_id,
    train_part.category_id
  from train
  full outer join train_part using (train_part_id)
;

CREATE VIEW "passenger_train_with_part" AS
  select
    train_with_part.*
  from train_with_part
  join category using (category_id)
  where
    substr(category.code, 1, 1) != 'G'
;

CREATE VIEW "station_with_location" AS
  select
    station.*,
    RL100,
    name_db,
    Laenge,
    Breite
  from station
  left join station_location on substr(replace(station_id, '_x0020_', ' '), 2) = station_location.RL100
;

CREATE VIEW "passenger_station" AS
  select distinct
    station_with_location.*
  from station_with_location
  join stop using (station_id)
  join passenger_train_with_part using (train_part_id)
;

CREATE TABLE IF NOT EXISTS "route_type" (
	"code"	TEXT NOT NULL,
	"route_type"	INTEGER NOT NULL,
  PRIMARY KEY ("code"),
  FOREIGN KEY ("code") REFERENCES "category"("code")
);
INSERT INTO "route_type" VALUES
 ('X',2),
 ('F',102),
 ('A',101),
 ('N',106),
 ('S',109),
 ('C',101),
 ('D',101),
 ('H',102),
 ('RRX',2),
 ('RbZ',106),
 ('B',101),
 ('AS',104)
;
