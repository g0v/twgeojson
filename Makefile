all:: twVillage1982.topo.json twTown1982.topo.json twCounty2010.topo.json twVote1982.topo.json

clean::
	rm -f tw*.geo.json tw*.topo.json
	rm -rf tmpdir

tmpdir:
	mkdir -p tmpdir

tmpdir/tw-town.rar:
	curl -o $@ http://www.iot.gov.tw/public/Attachment/71018174871.rar

tmpdir/tw-village.rar:
	curl -o $@ http://www.iot.gov.tw/public/Attachment/7101817115371.rar

tmpdir/tw-county.rar:
	curl -o $@ http://www.iot.gov.tw/public/Attachment/7101816594871.rar

tmpdir/TWN_VILLAGE.shp: tmpdir/tw-village.rar tmpdir
	(cd tmpdir && unrar x ../$<)
	touch $@

tmpdir/TWN_TOWN.shp: tmpdir/tw-town.rar tmpdir
	(cd tmpdir && unrar x ../$<)
	touch $@

tmpdir/TWN_COUNTY.shp: tmpdir/tw-county.rar tmpdir
	(cd tmpdir && unrar x ../$<)
	touch $@

# original command: ogr2ogr -f geojson $@ $<
twCounty2010.geo.json: tmpdir/TWN_COUNTY.shp
	./bin/shp2geojson.py $< $@

twTown1982.geo.json: tmpdir/TWN_TOWN.shp
	./bin/shp2geojson.py $< $@

twVillage1982.geo.json: tmpdir/TWN_VILLAGE.shp
	./bin/shp2geojson.py $< $@

twVote1982.geo.json: tmpdir/TWN_VILLAGE.shp
	./vote/shp2geojson-vote.py $< $@

.SUFFIXES: .geojson .topojson

%.topo.json:  %.geo.json
	./node_modules/.bin/topojson -p -s 0.00000001 $< > $@

