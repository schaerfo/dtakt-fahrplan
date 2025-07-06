# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

include definitions.mk

all: $(input_dir)/station_location_osm.csv

include common.mk

$(input_dir)/station_location_osm.csv: $(intermediate_dir)/dtakt-station-location.db missing_station_location.py .python
	poetry run python missing_station_location.py $< $@
