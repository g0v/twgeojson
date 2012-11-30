all:: twCounty1982.json twTown1982.json twCounty2010.json

clean::
	rm -f tw*.json

tmp/tw-town.rar:
	curl -o $@ http://www.iot.gov.tw/public/Attachment/71018174871.rar

tmp/tw-village.rar:
	curl -o $@ http://www.iot.gov.tw/public/Attachment/7101817115371.rar

tmp/tw-county.rar:
	curl -o $@ http://www.iot.gov.tw/public/Attachment/7101816594871.rar

tmp/TWN_TOWN.shp: tmp/tw-town.rar
	(cd tmp && unrar x ../$<)
	touch $@

tmp/TWN_COUNTY.shp: tmp/tw-county.rar
	(cd tmp && unrar x ../$<)
	touch $@

twCounty1982raw.json: tmp/TWN_COUNTY.shp
	ogr2ogr -f geojson $@ $<

twCounty1982.json: twCounty1982raw.json
	./node_modules/.bin/lsc bin/tw-counties.ls --simplify 0.0005 $< > $@

twCounty2010.json: twCounty1982raw.json
	./node_modules/.bin/lsc bin/tw-counties.ls --2010 --simplify 0.0005 $< > $@

twTown1982raw.json: tmp/TWN_TOWN.shp
	ogr2ogr -f geojson $@ $<

twTown1982.json: twTown1982raw.json
	./node_modules/.bin/lsc bin/tw-counties.ls --town --simplify 0.0005 $< > $@

twTown2010.json: twTown1982raw.json
	./node_modules/.bin/lsc bin/tw-counties.ls --town --2010 --simplify 0.0005 $< > $@
