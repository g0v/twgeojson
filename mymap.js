var projection, path, ref$, width, height, g, click, mymap;
projection = d3.geo.mercator().scale(50000).translate([-16500, 3650]);
path = d3.geo.path().projection(projection);
ref$ = [460, 600], width = ref$[0], height = ref$[1];
g = null;
click = function(d){
  var ref$, x, y, k, centered;
  ref$ = [0, 0, 1], x = ref$[0], y = ref$[1], k = ref$[2];
  if (d && centered != d) {
    ref$ = path.centroid(d), x = ref$[0], y = ref$[1];
    k = 4;
    x -= width / 2 / k;
    y -= height / 2 / k;
    centered = d;
  }
  g.selectAll("path").classed("active", centered && function(it){
    return it == centered;
  });
  return g.transition().duration(1000).attr("transform", "scale(" + k + ")translate(" + (-x) + "," + (-y) + ")").style("stroke-width", 1.5 / k + "px");
};
mymap = function(){
  var svg;
  svg = d3.select("body").append("svg").attr('width', width).attr('height', height);
  svg.append("rect").attr("class", "background").attr("width", width).attr("height", height).on("click", click);
  g = svg.append("g").append('g').attr('id', 'taiwan');
  return d3.json("twCounty1982.json", function(collection){
    return g.selectAll("path").data(collection.features).enter().append('path').attr('d', path).on('click', click);
  });
};