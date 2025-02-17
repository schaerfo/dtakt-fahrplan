# Copyright 2025 Christian Schärf
# SPDX-License-Identifier: MIT

input_dir := input

input: $(input_dir)/station_location.csv $(input_dir)/Export_fixed.railml.diff $(input_dir)/dtakt-schedule.zip

$(input_dir)/station_location.csv:
	wget "https://mirror.traines.eu/hafas-ibnr-zhv-gtfs-osm-matching/D_Bahnhof_2020_alle.CSV" -O $@

$(input_dir)/Export_fixed.railml.diff:
	wget https://gist.github.com/TheMinefighter/1ed90508f3fff466c43869c1b394b243/raw/7e4cb4983c3bf6e5e2b03564cd72a07a9f9c16cc/Export_fixed.railml.diff -O $@

$(input_dir)/dtakt-schedule.zip:
	wget "https://fragdenstaat.de/files/foi/519018/3.%20Gutachterentwurf%20Zielfahrplan%20Dtakt%20-%20maschienenlesbar.zip?download" -O $@
