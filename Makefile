all: intermediate/dtakt-schedule-patched.railml

intermediate/dtakt-schedule-patched.railml: intermediate/dtakt-schedule-lf.railml intermediate/Export_fixed.railml.diff
	cp $< $@
	patch $@ < intermediate/Export_fixed.railml.diff

intermediate/Export_fixed.railml.diff:
	wget https://gist.github.com/TheMinefighter/1ed90508f3fff466c43869c1b394b243/raw/7e4cb4983c3bf6e5e2b03564cd72a07a9f9c16cc/Export_fixed.railml.diff -O $@

intermediate/dtakt-schedule-lf.railml: intermediate/dtakt-schedule.railml
	cp $< $@
	dos2unix $@ 

intermediate/dtakt-schedule.railml: intermediate/dtakt-schedule.zip
	unzip -o -DD $<
	mv 200713_3GE_FV,NV,SGV_Export.railml $@

intermediate/dtakt-schedule.zip:
	wget "https://fragdenstaat.de/files/foi/519018/3.%20Gutachterentwurf%20Zielfahrplan%20Dtakt%20-%20maschienenlesbar.zip?download" -O $@

clean:
	rm -f intermediate/*
