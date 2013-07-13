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
  return d3.json("tw.json", function(tw){
    return d3.json("twCounty2010.topo.json", function(countiestopo){
      var proj, counties, villages, border, path, extent, x$, sg, regions, it, legend, update, g;
      proj = mtw();
      counties = topojson.feature(countiestopo, countiestopo.objects['twCounty2010.geo']);
      villages = topojson.feature(tw, tw.objects['villages']);
      border = topojson.mesh(tw, tw.objects['villages'], function(a, b){
        var ref$;
        return a === b && !/^(LJF|PEN|JME)/.test((ref$ = a.properties) != null ? ref$.ivid : void 8);
      });
      path = d3.geo.path().projection(proj);
      extent = path.bounds(counties);
      x$ = svg.append("defs");
      x$.append("path").attr("id", "border").datum(border).attr("d", path);
      x$.append("clipPath").attr("id", "clip").append("use").attr("xlink:href", '#border');
      sg = svg.append('g').attr("clip-path", 'url(#clip)');
      regions = d3.geom.voronoi().clipExtent(extent)((function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = stations).length; i$ < len$; ++i$) {
          it = ref$[i$];
          results$.push(proj([+it.longitude, +it.latitude, it.name]));
        }
        return results$;
      }()));
      legend = function(){
        var x$, y$;
        x$ = svg.selectAll("rect").data(rainscale.domain());
        x$.enter().append("rect").attr("x", 400).attr("y", function(d, i){
          return 380 - i * 20;
        }).attr("width", 20).attr("height", 20).attr("fill", function(d){
          return rainscale(d);
        });
        x$.enter().append("text").attr("x", 425).attr("y", function(d, i){
          return 400 - i * 20;
        }).text(function(it){
          return it;
        });
        y$ = svg.selectAll("text.description").data(['累積雨量', '毫米(mm)']);
        y$.enter().append("text").attr("class", 'descrition').attr("x", 425).attr("y", function(d, i){
          return 50 + 20 * i;
        }).text(function(it){
          return it;
        });
        return y$;
      };
      legend();
      update = function(){
        var paths;
        paths = sg.selectAll("path").data(regions);
        paths.enter().append("svg:path").attr("d", function(it){
          return "M" + it.join('L') + "Z";
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
        return sg.selectAll('circle').data(stations).enter().append('circle').style('stroke', 'gray').attr('r', 0.5).attr("transform", function(it){
          return "translate(" + proj([+it.longitude, +it.latitude]) + ")";
        });
      };
      g = svg.append('g').attr('class', 'villages');
      g.selectAll('path').data(counties.features).enter().append('path').attr('class', function(){
        return 'q-9-9';
      }).attr('d', path);
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
});