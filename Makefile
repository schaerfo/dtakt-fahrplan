intermediate_dir := intermediate
output_dir := out

all: $(output_dir)/dtakt-gtfs.zip

include input.mk
include python.mk

$(output_dir)/dtakt-gtfs.zip: $(intermediate_dir)/dtakt-gtfs.db export_gtfs.py .python
	poetry run python export_gtfs.py $< $@

$(intermediate_dir)/dtakt-gtfs.db: $(intermediate_dir)/dtakt-station-location-osm.db gtfs_views.sql
	cp $< $@
	sqlite3 $@ < gtfs_views.sql

$(intermediate_dir)/dtakt-station-location-osm.db: $(intermediate_dir)/dtakt-station-location.db $(intermediate_dir)/station-location-osm.json merge_station_location.py .python
	cp $< $@
	poetry run python merge_station_location.py $@ $(intermediate_dir)/station-location-osm.json

$(intermediate_dir)/station-location-osm.json: $(intermediate_dir)/overpass-query.txt
	curl -X POST -H "Content-Type: text/plain" --data @$< -o $@ https://overpass-api.de/api/interpreter
	# Incomplete results due to timeout have a "remark" item in the JSON root object
	test `jq '. | has("remark")' $@` != "true" || (rm $@; false)

$(intermediate_dir)/overpass-query.txt: $(intermediate_dir)/dtakt-station-location.db generate_overpass_query.py .python
	poetry run python generate_overpass_query.py $< > $@

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
