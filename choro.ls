width = 960
height = 500
rateById = d3.map!

quantize = d3.scale.quantize!domain [0, 0.15] .range (d3.range 9).map ((i) -> 'q' + i + '-9')

console.log d3.version

proj = mtw!scale 5000
#proj = mainland!scale 5000

path = d3.geo.path!projection proj

svg = d3.select 'body' .append 'svg' .attr 'width', width .attr 'height', height

#us <- d3.json "/twCounty1982.topojson"
us <- d3.json "/twVillage1982.topo.json"
#r <- d3.tsv "unemployment.tsv", (d) -> rateById.set d.id, +d.rate
svg.append 'g'
  .attr 'class', 'counties'
  .selectAll 'path'
  .data (topojson.object us, us.objects['twVillage1982.geo']).geometries
  .enter!append 'path'
  .style 'stroke', 'black'
#  .attr 'class', ({id}) -> quantize rateById.get id
  .attr 'd', path

svg.append 'path'
  .datum topojson.mesh us, us.objects['twVillage1982.geo'], (a, b) -> a isnt b
  .attr 'class', 'states'
  .attr 'd', path

