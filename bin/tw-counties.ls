argv = require \optimist .argv
town = argv.town
global.d3 = require \d3
require \d3-plugins/simplify/simplify
data = require "../#{argv._.0}"
by_county = {}

translate2010 = (name) ->
    | name is \台北縣 => \新北市
    | name is \台中縣 => \台中市
    | name is \台南縣 => \台南市
    | name is \高雄縣 => \高雄市
    | otherwise => name

key = ->
    name = it.COUNTYNAME
    name = translate2010 name if argv.2010
    if town
        name + it.TOWNNAME
    else
        name

for {properties,geometry,type} in data.features
    throw "not Feature: #type" unless type is \Feature
    throw "not Polygon" unless geometry.type is \Polygon
    name = key properties
    (by_county[name] ||= []).push geometry.coordinates

features = for name, coordinates of by_county => do
    properties: {name}
    type: \Feature
    geometry: do
        if coordinates.length is 1
            type: \Polygon
            coordinates: coordinates[0]
        else
            { type: \MultiPolygon, coordinates }

if argv.simplify
    simplify = d3.simplify!topology true .area argv.simplify .projection -> it

    for {geometry}:f in features
        p = simplify simplify.project geometry
        for polygon in p.coordinates
            polygon.forEach -> it.pop!
        f.geometry.coordinates = p.coordinates

console.log JSON.stringify {type: \FeatureCollection, features} , null, 4
