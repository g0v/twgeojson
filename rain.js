var width, height, census, svg;
width = window.innerWidth * 0.8;
height = window.innerHeight - 10;
census = d3.map();
svg = d3.select('body').append('svg').attr('width', width).attr('height', height);
d3.json("stations.json", function(stations){
  var root, current, rainscale, rainToday;
  root = new Firebase("https://cwbtw.firebaseio.com");
  current = root.child("rainfall/current");
  rainscale = d3.scale.quantile().domain([1, 2, 6, 10, 15, 20, 30, 40, 50, 70, 90, 110, 130, 150, 200, 300]).range(['#c5bec2', '#99feff', '#00ccfc', '#0795fd', '#025ffe', '#3c9700', '#2bfe00', '#fdfe00', '#ffcb00', '#eaa200', '#f30500', '#d60002', '#9e0003', '#9e009d', '#d400d1', '#fa00ff', '#facefb']);
  rainToday = {};
  return d3.json("twCounty2010.topo.json", function(tw){
    var proj, county, border, polygon, path, extent, sg, regions, it, update, g, bo;
    proj = mtw();
    county = topojson.feature(tw, tw.objects['twCounty2010.geo']);
    border = topojson.mesh(tw, tw.objects['twCounty2010.geo'], function(a, b){
      return a === b;
    });
    path = d3.geo.path().projection(proj);
    window.county = county;
    extent = path.bounds(county);
    sg = svg.append('g');
    regions = d3.geom.voronoi().clipExtent(extent)((function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = stations).length; i$ < len$; ++i$) {
        it = ref$[i$];
        results$.push(proj([+it.longitude, +it.latitude, it.name]));
      }
      return results$;
    }()));
    update = function(){
      var paths;
      paths = sg.selectAll("path").data(regions);
      paths.enter().append("svg:path").attr("d", function(it){
        var z, clipped;
        if (!polygon) {
          return "M" + it.join('L') + "Z";
        }
        z = it;
        clipped = polygon.clip(it);
        if (clipped.length) {
          return "M" + clipped.join('L') + "Z";
        } else {
          return null;
        }
      });
      paths.style('fill', function(d, i){
        var today, ref$;
        today = +((ref$ = rainToday[stations[i].name]) != null ? ref$.today : void 8);
        if (today === NaN) {
          today = null;
        }
        if (today) {
          return rainscale(today);
        } else {
          return '#fff';
        }
      });
      return sg.selectAll('circle').data(stations).enter().append('circle').style('stroke', 'black').attr('r', 1).attr("transform", function(it){
        return "translate(" + proj([+it.longitude, +it.latitude]) + ")";
      });
    };
    g = svg.append('g').attr('class', 'villages');
    g.selectAll('path').data(county.features).enter().append('path').attr('class', function(){
      return 'q-9-9';
    }).attr('d', path);
    bo = svg.append('path').attr('class', 'border').datum(border).attr('class', 'border').attr('d', path);
    current.on('value', function(it){
      var ref$, time, data, today, res$, name, parsed;
      ref$ = it.val(), time = ref$.time, data = ref$.data;
      d3.select('#time').text(time);
      rainToday = data;
      res$ = [];
      for (name in data) {
        today = data[name].today;
        if (parsed = parseFloat(today)) {
          res$.push(parsed);
        }
      }
      today = res$;
      return update();
    });
    return [];
  });
});