all:: twCounty1982.json twTown1982.json twCounty2010.json

clean::
	rm -f tw*.json
	rm -rf tmpdir

tmpdir:
	mkdir -p tmpdir

tmpdir/tw-town.rar: tmpdir
	curl -o $@ http://www.iot.gov.tw/public/Attachment/71018174871.rar

tmpdir/tw-village.rar: tmpdir
	curl -o $@ http://www.iot.gov.tw/public/Attachment/7101817115371.rar

tmpdir/tw-county.rar: tmpdir
	curl -o $@ http://www.iot.gov.tw/public/Attachment/7101816594871.rar

tmpdir/TWN_TOWN.shp: tmpdir/tw-town.rar tmpdir
	(cd tmpdir && unrar x ../$<)
	touch $@

tmpdir/TWN_COUNTY.shp: tmpdir/tw-county.rar tmpdir
	(cd tmpdir && unrar x ../$<)
	touch $@

twCounty1982raw.json: tmpdir/TWN_COUNTY.shp
	ogr2ogr -f geojson $@ $<

twCounty1982.json: twCounty1982raw.json
	./node_modules/.bin/lsc bin/tw-counties.ls --simplify 0.0005 $< > $@

twCounty2010.json: twCounty1982raw.json
	./node_modules/.bin/lsc bin/tw-counties.ls --2010 --simplify 0.0005 $< > $@

twTown1982raw.json: tmpdir/TWN_TOWN.shp
	ogr2ogr -f geojson $@ $<

twTown1982.json: twTown1982raw.json
	./node_modules/.bin/lsc bin/tw-counties.ls --town --simplify 0.0005 $< > $@

twTown2010.json: twTown1982raw.json
	./node_modules/.bin/lsc bin/tw-counties.ls --town --2010 --simplify 0.0005 $< > $@
