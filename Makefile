all: intermediate/dtakt-schedule.railml

intermediate/dtakt-schedule.railml: intermediate/dtakt-schedule.zip
	unzip -o -DD $<
	mv 200713_3GE_FV,NV,SGV_Export.railml $@

intermediate/dtakt-schedule.zip:
	wget "https://fragdenstaat.de/files/foi/519018/3.%20Gutachterentwurf%20Zielfahrplan%20Dtakt%20-%20maschienenlesbar.zip?download" -O $@

clean:
	rm -f intermediate/*
