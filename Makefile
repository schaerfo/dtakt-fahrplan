# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

include definitions.mk

all: $(output_dir)/dtakt-gtfs.zip

include common.mk

$(output_dir)/dtakt-gtfs.zip: $(intermediate_dir)/dtakt-gtfs.db export_gtfs.py .python
	poetry run python export_gtfs.py $< $@

$(intermediate_dir)/dtakt-gtfs.db: $(intermediate_dir)/dtakt-station-location-osm.db gtfs_views.sql
	cp $< $@
	sqlite3 $@ < gtfs_views.sql

$(intermediate_dir)/dtakt-station-location-osm.db: $(intermediate_dir)/dtakt-station-location.db $(input_dir)/station_location_osm.csv merge_station_location.py .python
	cp $< $@
	poetry run python merge_station_location.py $@ $(input_dir)/station_location_osm.csv

clean: clean-input clean-intermediate clean-output

clean-input:
	rm -f $(input_dir)/*

clean-intermediate:
	rm -f $(intermediate_dir)/*

clean-output:
	rm -f $(output_dir)/*
