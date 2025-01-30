BEGIN TRANSACTION;
CREATE VIEW "gtfs_agency" AS
  select
    1 as agency_id,
    'Deutschlandtakt' as agency_name,
    'https://www.deutschlandtakt.de' as agency_url,
    'Europe/Berlin' as agency_timezone
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

CREATE VIEW "train_with_part" AS
  select
    train.id,
    train.dtakt_id,
    train.description,
    train.train_number,
    train.line_name,
    train.group_id,
    train_part.id as train_part_id,
    train_part.category_id
  from train
  full outer join train_part on train.train_part_id = train_part.id
;

CREATE VIEW "passenger_train_with_part" AS
  select
    * from train_with_part
  join category on train_with_part.category_id = category.id
  where
    substr(category.code, 1, 1) != "G"
;

CREATE VIEW "gtfs_routes" AS
  select
    group_id as route_id,
    (select agency_id from gtfs_agency) as agency_id,
    description as route_long_name,
    line_name as route_short_name,
    2 as route_type
  from passenger_train_with_part
  group by group_id
  order by code, line_name, description
;

CREATE VIEW "gtfs_trips" AS
  select
    group_id as route_id,
    (select service_id from gtfs_calendar) as service_id,
    id as trip_id
  from passenger_train_with_part
;

CREATE VIEW "gtfs_stops" AS
  select
    id as stop_id,
    name_db as stop_name,
    Breite as stop_lat,
    Laenge as stop_lon,
    1 as location_type,
    NULL as parent_station
  from station_location
;

CREATE VIEW "gtfs_stop_times" AS
  select
    passenger_train_with_part.id as trip_id,
    station_id as stop_id,
    iif(arrival is null, departure, arrival) as arrival_time,
    iif(departure is null, arrival, departure) as departure_time,
    sequence as stop_sequence
  from stop
  join passenger_train_with_part on stop.train_part_id = passenger_train_with_part.train_part_id
  join station_location on stop.station_id = station_location.id
  where
      arrival_time is not null
    and
      Laenge is not null
;
COMMIT;
