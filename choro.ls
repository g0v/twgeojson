width = 960
height = 500
rateById = d3.map!

quantize = d3.scale.quantize!domain [0, 0.15] .range (d3.range 9).map ((i) -> 'q' + i + '-9')

svg = d3.select 'body' .append 'svg' .attr 'width', width .attr 'height', height

tw <- d3.json "/tw.json"

proj = mtw!

villages = topojson.feature tw, tw.objects['villages']

path = d3.geo.path!projection proj
# scale to fit
b = path.bounds villages
s = 0.95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height)
t = [(width - s * (b.1.0 + b.0.0)) / 2, (height - s * (b.1.1 + b.0.1)) / 2]

proj.scale proj.scale!/s

svg.append 'g'
  .attr 'class', 'counties'
  .selectAll 'path'
  .data villages.features
  .enter!append 'path'
#  .attr 'class', ({id}) -> quantize rateById.get id
  .attr 'd', path

svg.append 'path'
  .datum topojson.mesh tw, tw.objects['villages'], (a, b) -> a is b
  .attr 'class', 'states'
  .style \stroke \black
  .attr 'd', path

