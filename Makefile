#config simplify factor for each topojson
twVillage1982.topo.json.simplify=0.00000008
twTown1982.topo.json.simplify=0.00000005
twCounty2010.topo.json.simplify=0.00000008
twVote1982.topo.json.simplify=0.0000001


all: json/twVillage1982.topo.json json/twTown1982.topo.json json/twCounty2010.topo.json json/twVote1982.topo.json

clean:
	rm -f json/tw*.geo.json json/tw*.topo.json
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
json/twCounty2010.topo.json: tmpdir/TWN_COUNTY.shp
	./node_modules/.bin/mapshaper -p 0.01 $< -f topojson --encoding big5 -o $@

json/twTown1982.topo.json: tmpdir/TWN_TOWN.shp
	./node_modules/.bin/mapshaper -p 0.01 $< -f topojson --encoding big5 -o $@

json/twVillage1982.topo.json: tmpdir/TWN_VILLAGE.shp
	./node_modules/.bin/mapshaper -p 0.01 $< -f topojson --encoding big5 -o $@

json/twVote1982.topo.json: tmpdir/TWN_VILLAGE.shp
	./node_modules/.bin/mapshaper -p 0.01 $< -f topojson --encoding big5 -o $@

vote: json/twVote1982.topo.json
village: json/twVillage1982.topo.json
town: json/twTown1982.topo.json
county: json/twCounty1982.topo.json

clean-topo:
	rm json/tw*.topo.json

nlsc:
	lsc cleanup-nlsc.ls > json/villages.json
	ogr2ogr -f 'ESRI Shapefile' tmpdir/tw-fixed/ json/villages.json  -lco ENCODING=UTF-8
