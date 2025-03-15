-- Copyright 2025 Christian Schärf
-- SPDX-License-Identifier: MIT

BEGIN TRANSACTION;
CREATE VIEW "gtfs_agency" AS
  select
    1 as agency_id,
    'Deutschlandtakt' as agency_name,
    'https://www.deutschlandtakt.de' as agency_url,
    'Etc/UTC' as agency_timezone
;

CREATE VIEW "gtfs_calendar" AS
  select
    1 service_id,
    1 as monday,
    1 as tuesday,
    1 as wednesday,
    1 as thursday,
    1 as friday,
    1 as saturday,
    1 as sunday,
    20241215 as start_date,
    20251213 as end_date
;

CREATE VIEW "gtfs_routes" AS
  select distinct
    group_id as route_id,
    (select agency_id from gtfs_agency) as agency_id,
    passenger_train_with_part.description as route_long_name,
    line_name as route_short_name,
	route_type
  from passenger_train_with_part
  left join category using (category_id)
  left join route_type using (code)
;

CREATE VIEW "gtfs_trips" AS
  select
    group_id as route_id,
    (select service_id from gtfs_calendar) as service_id,
    train_id as trip_id,
    trip_headsign
  from passenger_train_with_part
  join (
    select
      stop1.train_part_id,
      station_id,
      name_db as trip_headsign
    from (
      select
        train_part_id,
        max(sequence) as sequence
      from stop
      join passenger_station using (station_id)
      where name_db is not null
      group by train_part_id
    ) as stop1
    join stop using (train_part_id, sequence)
    join passenger_station using (station_id)
  ) using (train_part_id)
;

CREATE VIEW "gtfs_stops" AS
  select
    station_id as stop_id,
    name_db as stop_name,
    Breite as stop_lat,
    Laenge as stop_lon
  from passenger_station
  where Laenge is not null
;

CREATE VIEW "gtfs_stop_times" AS
  select
    passenger_train_with_part.train_id as trip_id,
    station_id as stop_id,
    iif(arrival is null, departure, arrival) as arrival_time,
    iif(departure is null, arrival, departure) as departure_time,
    sequence as stop_sequence
  from stop
  join passenger_train_with_part using (train_part_id)
  join station_with_location using (station_id)
  where
      arrival_time is not null
    and
      Laenge is not null
;
COMMIT;
