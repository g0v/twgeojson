var projection, path, ref$, width, height, g, click, data, quantize, mymap;
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
data = null;
quantize = function(it){
  var ref$, pct, ret;
  pct = parseFloat((ref$ = data[it.properties.name]) != null ? ref$.percentage : void 8);
  ret = 'q' + Math.min(8, pct * 9 / 12) + '-9';
  return ret;
};
mymap = function(){
  var svg;
  svg = d3.select("body").append("svg").attr('width', width).attr('height', height);
  svg.append("rect").attr("class", "background").attr("width", width).attr("height", height).on("click", click);
  g = svg.append("g").append('g').attr('id', 'taiwan').attr('class', 'Blues');
  return d3.tsv("test.tsv", function(d){
    var eligibles, res$, i$, len$, entry, city, name, x, baseEligible, baseArea;
    console.log(d);
    eligibles = d.map(function(it){
      return it.eligible;
    });
    res$ = {};
    for (i$ = 0, len$ = d.length; i$ < len$; ++i$) {
      entry = d[i$], city = entry.city;
      res$[city.replace(/臺/g, '台')] = entry;
    }
    data = res$;
    baseEligible = (function(){
      var ref$, results$ = [];
      for (name in ref$ = data) {
        x = ref$[name];
        if (name === '台北市') {
          results$.push(+x.eligible);
        }
      }
      return results$;
    }())[0];
    baseArea = null;
    d3.json("twCounty2010.json", function(collection){
      var res$, i$, ref$, len$, f, areas, properties;
      res$ = [];
      for (i$ = 0, len$ = (ref$ = collection.features).length; i$ < len$; ++i$) {
        f = ref$[i$];
        res$.push(f.properties.area = Math.abs(path.area(f)));
      }
      areas = res$;
      baseArea = (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = collection.features).length; i$ < len$; ++i$) {
          properties = ref$[i$].properties;
          if (properties.name === '台北市') {
            results$.push(properties.area);
          }
        }
        return results$;
      }())[0];
      return g.selectAll("path").data(collection.features).enter().append('path').attr('class', data ? quantize : null).attr('d', path).on('click', click);
    });
    d3.select('#bar').on('click', function(){
      return g.selectAll('path').transition().duration(1000).attr('transform', function(){
        return "scale(1)";
      });
    });
    return d3.select('#foo').on('click', function(){
      return g.selectAll('path').transition().duration(1000).attr('transform', function(it){
        var ref$, name, area, entry, scale, x, y;
        ref$ = it.properties, name = ref$.name, area = ref$.area;
        entry = data[name];
        scale = 1;
        if (entry != null) {
          console.log(baseEligible, baseArea);
          scale = entry.eligible / baseEligible;
          scale *= Math.sqrt(baseArea / it.properties.area);
          console.log('toscale');
          console.log(name, scale, area, area / baseArea, entry.eligible, entry.eligible / baseEligible);
        }
        ref$ = path.centroid(it), x = ref$[0], y = ref$[1];
        return ("translate(" + x + "," + y + ")") + ("scale(" + scale + ")") + ("translate(" + (-x) + "," + (-y) + ")");
      });
    });
  });
};