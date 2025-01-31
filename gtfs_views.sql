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

CREATE VIEW "gtfs_routes" AS
  select distinct
    group_id as route_id,
    (select agency_id from gtfs_agency) as agency_id,
    description as route_long_name,
    line_name as route_short_name,
    2 as route_type
  from passenger_train_with_part
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
  from passenger_station
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
  join station_with_location on stop.station_id = station_with_location.id
  where
      arrival_time is not null
    and
      Laenge is not null
;
COMMIT;
