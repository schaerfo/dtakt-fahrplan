# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

include input.mk
include python.mk

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
