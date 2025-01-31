input_dir := input
intermediate_dir := intermediate
output_dir := out

all: $(output_dir)/dtakt-gtfs.zip

$(output_dir)/dtakt-gtfs.zip: $(intermediate_dir)/dtakt-gtfs.db export_gtfs.py .python
	poetry run python export_gtfs.py $< $@

$(intermediate_dir)/dtakt-gtfs.db: $(intermediate_dir)/dtakt-station-location.db gtfs_views.sql
	cp $< $@
	sqlite3 $@ < gtfs_views.sql

$(intermediate_dir)/dtakt-station-location.db: $(intermediate_dir)/dtakt.db $(input_dir)/station_location.csv passenger_train_view.sql station_location.py .python
	cp $< $@
	poetry run python station_location.py $@ $(input_dir)/station_location.csv
	sqlite3 $@ < passenger_train_view.sql

$(input_dir)/station_location.csv:
	wget "https://mirror.traines.eu/hafas-ibnr-zhv-gtfs-osm-matching/D_Bahnhof_2020_alle.CSV" -O $@

$(intermediate_dir)/dtakt.db: $(intermediate_dir)/dtakt-schedule-patched.railml db_ingest.py .python
	poetry run python db_ingest.py $< $@

.python: pyproject.toml poetry.lock
	poetry install --sync
	touch .python

$(intermediate_dir)/dtakt-schedule-patched.railml: $(intermediate_dir)/dtakt-schedule-lf.railml $(input_dir)/Export_fixed.railml.diff
	cp $< $@
	patch $@ < $(input_dir)/Export_fixed.railml.diff

$(input_dir)/Export_fixed.railml.diff:
	wget https://gist.github.com/TheMinefighter/1ed90508f3fff466c43869c1b394b243/raw/7e4cb4983c3bf6e5e2b03564cd72a07a9f9c16cc/Export_fixed.railml.diff -O $@

$(intermediate_dir)/dtakt-schedule-lf.railml: $(intermediate_dir)/dtakt-schedule.railml
	cp $< $@
	dos2unix $@ 

$(intermediate_dir)/dtakt-schedule.railml: $(input_dir)/dtakt-schedule.zip
	unzip -o -DD $<
	mv 200713_3GE_FV,NV,SGV_Export.railml $@

$(input_dir)/dtakt-schedule.zip:
	wget "https://fragdenstaat.de/files/foi/519018/3.%20Gutachterentwurf%20Zielfahrplan%20Dtakt%20-%20maschienenlesbar.zip?download" -O $@

clean:
	rm -f $(intermediate_dir)/*
