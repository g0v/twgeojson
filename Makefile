#config simplify factor for each topojson
twVillage1982.topo.json.simplify=0.00000008
twTown1982.topo.json.simplify=0.00000005
twCounty2010.topo.json.simplify=0.00000008
twVote1982.topo.json.simplify=0.0000001


all: twVillage1982.topo.json twTown1982.topo.json twCounty2010.topo.json twVote1982.topo.json

clean:
	rm -f tw*.geo.json tw*.topo.json
	rm -rf tmpdir

tmpdir:
	mkdir -p tmpdir

tmpdir/tw-town.rar: | tmpdir
	curl -o $@ http://www.iot.gov.tw/public/Attachment/71018174871.rar

tmpdir/tw-village.rar: | tmpdir
	curl -o $@ http://www.iot.gov.tw/public/Attachment/7101817115371.rar

tmpdir/tw-county.rar: | tmpdir
	curl -o $@ http://www.iot.gov.tw/public/Attachment/7101816594871.rar

tmpdir/TWN_VILLAGE.shp: tmpdir/tw-village.rar
	(cd tmpdir && unrar x ../$<)
	touch $@

tmpdir/TWN_TOWN.shp: tmpdir/tw-town.rar
	(cd tmpdir && unrar x ../$<)
	touch $@

tmpdir/TWN_COUNTY.shp: tmpdir/tw-county.rar
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
	$(eval simplify=${${@}.simplify})
	$(eval simplify=$(if ${simplify},${simplify},0.00000001))
	./node_modules/.bin/topojson -p -s ${simplify} $< > $@

vote: twVote1982.topo.json
village: twVillage1982.topo.json
town: twTown1982.topo.json
county: twCounty1982.topo.json

clean-topo:
	rm tw*.topo.json

nlsc:
	lsc cleanup-nlsc.ls > villages.json
	ogr2ogr -f 'ESRI Shapefile' tmpdir/tw-fixed/ villages.json  -lco ENCODING=UTF-8

villages.json: nlsc

tw.json: villages.json
	topojson -s 1e-10 -q 1e6 -o tw.json villages.json --id-property V_ID -p ivid -e ./districts.csv
