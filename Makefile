# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

intermediate_dir := intermediate
output_dir := out

all: $(output_dir)/dtakt-gtfs.zip

include input.mk
include python.mk

$(output_dir)/dtakt-gtfs.zip: $(intermediate_dir)/dtakt-gtfs.db export_gtfs.py .python
	poetry run python export_gtfs.py $< $@

$(intermediate_dir)/dtakt-gtfs.db: $(intermediate_dir)/dtakt-station-location-missing.db gtfs_views.sql
	cp $< $@
	sqlite3 $@ < gtfs_views.sql

$(intermediate_dir)/dtakt-station-location-missing.db: $(intermediate_dir)/dtakt-station-location.db missing_station_location.py .python
	cp $< $@
	poetry run python missing_station_location.py $@

$(intermediate_dir)/dtakt-station-location.db: $(intermediate_dir)/dtakt.db $(input_dir)/station_location.csv passenger_train_view.sql station_location.py .python
	cp $< $@
	poetry run python station_location.py $@ $(input_dir)/station_location.csv
	sqlite3 $@ < passenger_train_view.sql

$(intermediate_dir)/dtakt.db: $(intermediate_dir)/dtakt-schedule-patched.railml db_ingest.py .python
	poetry run python db_ingest.py $< $@

$(intermediate_dir)/dtakt-schedule-patched.railml: $(intermediate_dir)/dtakt-schedule-lf.railml $(input_dir)/Export_fixed.railml.diff
	cp $< $@
	patch $@ < $(input_dir)/Export_fixed.railml.diff

$(intermediate_dir)/dtakt-schedule-lf.railml: $(intermediate_dir)/dtakt-schedule.railml
	cp $< $@
	dos2unix $@ 

$(intermediate_dir)/dtakt-schedule.railml: $(input_dir)/dtakt-schedule.zip
	unzip -o -DD $<
	mv 200713_3GE_FV,NV,SGV_Export.railml $@

clean: clean-input clean-intermediate clean-output

clean-input:
	rm -f $(input_dir)/*

clean-intermediate:
	rm -f $(intermediate_dir)/*

clean-output:
	rm -f $(output_dir)/*
