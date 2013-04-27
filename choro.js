var width, height, rateById, quantize, svg;
width = 960;
height = 500;
rateById = d3.map();
quantize = d3.scale.quantize().domain([0, 0.15]).range(d3.range(9).map(function(i){
  return 'q' + i + '-9';
}));
svg = d3.select('body').append('svg').attr('width', width).attr('height', height);
d3.json("/tw.json", function(tw){
  var proj, villages, path, b, s, t;
  proj = mtw();
  villages = topojson.feature(tw, tw.objects['villages']);
  path = d3.geo.path().projection(proj);
  b = path.bounds(villages);
  s = 0.95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height);
  t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2];
  proj.scale(proj.scale() / s);
  svg.append('g').attr('class', 'counties').selectAll('path').data(villages.features).enter().append('path').attr('d', path);
  return svg.append('path').datum(topojson.mesh(tw, tw.objects['villages'], function(a, b){
    return a === b;
  })).attr('class', 'states').style('stroke', 'black').attr('d', path);
});