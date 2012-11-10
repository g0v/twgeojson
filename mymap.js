var projection, path, ref$, width, height, g, click, data, pctscale, quantize, edge, collide, dolinks, mymap;
projection = d3.geo.mercator().scale(50000).translate([-16400, 3800]);
path = d3.geo.path().projection(projection);
ref$ = [600, 800], width = ref$[0], height = ref$[1];
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
pctscale = null;
quantize = function(it){
  var ref$;
  return "q" + pctscale(parseFloat((ref$ = data[it.properties.name]) != null ? ref$.percentage : void 8)) + "-9";
};
edge = function(a, b){
  var dx, dy;
  dx = a.x - b.x;
  dy = a.y - b.y;
  return {
    source: a,
    target: b,
    distance: Math.sqrt(dx * dx + dy * dy)
  };
};
collide = function(node){
  var r, nx1, nx2, ny1, ny2;
  r = node.radius + 16;
  nx1 = node.x - r;
  nx2 = node.x + r;
  ny1 = node.y - r;
  ny2 = node.y + r;
  return function(quad, x1, y1, x2, y2){
    var x, y, l;
    if (quad.point && quad.point !== node) {
      x = node.x - quad.point.x;
      y = node.y - quad.point.y;
      l = Math.sqrt(x * x + y * y);
      r = node.radius + quad.point.radius;
      if (l < r) {
        l = (l - r) / l * 0.5;
        node.x -= x *= l;
        node.y -= y *= l;
        quad.point.x += x;
        quad.point.y += y;
      }
    }
    return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1;
  };
};
dolinks = function(svg, nodes, links){
  var force, parent, node, link;
  force = d3.layout.force().size([width, height]);
  force.gravity(0).friction(0.1).charge(0).nodes(nodes).links(links).linkDistance(function(it){
    return it.distance;
  }).size([width, height]).start();
  parent = g.selectAll('g').data(nodes).enter().append('g').attr('transform', function(it){
    return "translate(" + (-it.x) + "," + (-it.y) + ")";
  }).call(force.drag);
  node = parent.append('path').attr('transform', function(it){
    return "translate(" + it.x + "," + it.y + ")";
  }).attr('class', function(it){
    return quantize(it.feature);
  }).attr("d", function(it){
    return path(it.feature);
  }).on('click', function(it){
    return click(it.feature);
  });
  link = g.selectAll('line').data(links).enter().append('line').attr('x1', function(it){
    return it.source.x;
  }).attr('y1', function(it){
    return it.source.y;
  }).attr('x2', function(it){
    return it.target.x;
  }).attr('y2', function(it){
    return it.target.y;
  });
  force.on('tick', function(e){
    var q, i$, ref$, len$, n;
    link.attr('x1', function(it){
      return it.source.x;
    }).attr('y1', function(it){
      return it.source.y;
    }).attr('x2', function(it){
      return it.target.x;
    }).attr('y2', function(it){
      return it.target.y;
    });
    q = d3.geom.quadtree(nodes);
    for (i$ = 0, len$ = (ref$ = nodes).length; i$ < len$; ++i$) {
      n = ref$[i$];
      q.visit(collide(n));
    }
    return node.attr('transform', function(it){
      var ref$, me, ref1$, x, y, scale;
      it.x <= (ref$ = width - it.radius) || (it.x = ref$);
      it.x >= (ref$ = it.radius) || (it.x = ref$);
      it.y <= (ref$ = height - it.radius) || (it.y = ref$);
      it.y >= (ref$ = it.radius) || (it.y = ref$);
      me = "translate(" + it.x + "," + it.y + ")";
      if (it.feature.x) {
        ref1$ = [(ref$ = it.feature)['x'], ref$['y'], ref$['scale']], x = ref1$[0], y = ref1$[1], scale = ref1$[2];
        me += ("translate(" + x + "," + y + ")") + ("scale(" + scale + ")") + ("translate(" + (-x) + "," + (-y) + ")");
      }
      return me;
    });
  });
  force.start();
  return force;
};
mymap = function(){
  var svg;
  svg = d3.select('body').append('svg').attr('width', width).attr('height', height);
  svg.append('rect').attr('class', 'background').attr('width', width).attr('height', height).on('click', click);
  g = svg.append("g").append('g').attr('id', 'taiwan').attr('class', 'Blues');
  return d3.tsv("test.tsv", function(d){
    var eligibles, adj, res$, i$, len$, entry, city, useBase, name, x, baseEligible, baseArea, force, showlinks;
    eligibles = d.map(function(it){
      return it.eligible;
    });
    adj = [['台北市', '新北市'], ['新北市', '基隆市'], ['新北市', '宜蘭縣'], ['新北市', '桃園縣'], ['桃園縣', '宜蘭縣'], ['桃園縣', '新竹縣'], ['新竹縣', '宜蘭縣'], ['新竹縣', '新竹市'], ['新竹縣', '苗栗縣'], ['苗栗縣', '台中市'], ['新竹縣', '台中市'], ['宜蘭縣', '花蓮縣'], ['台中市', '花蓮縣'], ['台中市', '彰化縣'], ['台中市', '南投縣'], ['花蓮縣', '南投縣'], ['彰化縣', '南投縣'], ['彰化縣', '雲林縣'], ['南投縣', '雲林縣'], ['雲林縣', '嘉義縣'], ['南投縣', '嘉義縣'], ['嘉義縣', '嘉義市'], ['嘉義縣', '高雄市'], ['嘉義縣', '台南市'], ['高雄市', '台南市'], ['花蓮縣', '高雄市'], ['花蓮縣', '台東縣'], ['台東縣', '高雄市'], ['台東縣', '屏東縣'], ['高雄市', '屏東縣']];
    res$ = {};
    for (i$ = 0, len$ = d.length; i$ < len$; ++i$) {
      entry = d[i$], city = entry.city;
      res$[city.replace(/臺/g, '台')] = entry;
    }
    data = res$;
    useBase = '台南市';
    baseEligible = (function(){
      var ref$, results$ = [];
      for (name in ref$ = data) {
        x = ref$[name];
        if (name === useBase) {
          results$.push(+x.eligible);
        }
      }
      return results$;
    }())[0];
    baseArea = null;
    force = null;
    pctscale = d3.scale.quantile().domain(d3.extent(d, function(it){
      return parseFloat(it.percentage);
    })).range([1, 2, 3, 4, 5, 6, 7, 8]);
    console.log(d);
    d3.json("twCounty2010.json", function(collection){
      var byname, res$, i$, ref$, len$, f, areas, feature, ref1$, x, y, radius, nodes, links, a, b, morelinks, properties;
      byname = {};
      res$ = [];
      for (i$ = 0, len$ = (ref$ = collection.features).length; i$ < len$; ++i$) {
        f = ref$[i$];
        res$.push(f.properties.area = Math.abs(path.area(f)));
      }
      areas = res$;
      res$ = [];
      for (i$ = 0, len$ = (ref$ = collection.features).length; i$ < len$; ++i$) {
        feature = ref$[i$];
        ref1$ = path.centroid(feature), x = ref1$[0], y = ref1$[1];
        radius = 0;
        res$.push(byname[feature.properties.name] = {
          feature: feature,
          x: x,
          y: y,
          radius: radius
        });
      }
      nodes = res$;
      links = [];
      for (i$ = 0, len$ = (ref$ = adj).length; i$ < len$; ++i$) {
        ref1$ = ref$[i$], a = ref1$[0], b = ref1$[1];
        links.push(edge(byname[a], byname[b]));
      }
      morelinks = function(){
        var res$, i$, ref$, len$, x, res1$, j$, ref1$, len1$, y, res;
        res$ = [];
        for (i$ = 0, len$ = (ref$ = nodes).length; i$ < len$; ++i$) {
          x = ref$[i$];
          if (/金門|連江|澎湖/.exec(x.feature.properties.name)) {
            res1$ = [];
            for (j$ = 0, len1$ = (ref1$ = nodes).length; j$ < len1$; ++j$) {
              y = ref1$[j$];
              if (x !== y) {
                res1$.push(edge(x, y));
              }
            }
            y = res1$;
            y.sort(fn$);
            res$.push([y[0], y[1], y[2], y[3], y[4], y[5]]);
          }
        }
        res = res$;
        return links = links.concat(res.reduce(curry$(function(x$, y$){
          return x$.concat(y$);
        })));
        function fn$(a, b){
          return a.distance - b.distance;
        }
      };
      morelinks();
      force = dolinks(svg, nodes, links);
      return ref$ = (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = collection.features).length; i$ < len$; ++i$) {
          properties = ref$[i$].properties;
          if (properties.name === useBase) {
            results$.push(properties.area);
          }
        }
        return results$;
      }()), baseArea = ref$[0], ref$;
    });
    showlinks = false;
    d3.select('#showlinks').on('click', function(){
      return g.selectAll('line').classed("show", showlinks = !showlinks);
    });
    d3.select('#restore').on('click', function(){
      force.stop();
      g.selectAll('path').each(function(d){
        var it, ref$;
        it = d.feature;
        it.scale = 1;
        ref$ = path.centroid(it), d.x = ref$[0], d.y = ref$[1];
        d.radius = 0;
        return d.distance = d.origDistance;
      }).transition().duration(1000).attr('transform', function(it){
        var ref$, x, y, scale;
        ref$ = it.feature, x = ref$.x, y = ref$.y, scale = ref$.scale;
        return ("translate(" + it.x + "," + it.y + ")") + ("translate(" + x + "," + y + ")") + ("scale(" + scale + ")") + ("translate(" + (-x) + "," + (-y) + ")");
      });
      return flip$(setTimeout)(1000, function(){
        return force.charge(0).resume();
      });
    });
    return d3.select('#scale').on('click', function(){
      force.stop();
      g.selectAll('path').each(function(d){
        var it, ref$, name, area, entry, scale, x, y;
        it = d.feature;
        ref$ = it.properties, name = ref$.name, area = ref$.area;
        entry = data[name];
        scale = 1;
        if (entry != null) {
          console.log(baseEligible, baseArea);
          it.eligible = entry.eligible;
          scale = entry.eligible / baseEligible;
          scale *= baseArea / it.properties.area;
          scale = Math.sqrt(scale);
          console.log('toscale');
          console.log(name, scale, area, area / baseArea, entry.eligible, entry.eligible / baseEligible);
          console.log(d, d3.geo.bounds(it));
          d.radius = Math.sqrt(area / Math.PI) * 1.2 * scale;
        }
        ref$ = path.centroid(it), x = ref$[0], y = ref$[1];
        return it.scale = scale, it.x = x, it.y = y, it;
      }).transition().duration(1000).attr('transform', function(it){
        var ref$, x, y, scale;
        ref$ = it.feature, x = ref$.x, y = ref$.y, scale = ref$.scale;
        return ("translate(" + it.x + "," + it.y + ")") + ("translate(" + x + "," + y + ")") + ("scale(" + scale + ")") + ("translate(" + (-x) + "," + (-y) + ")");
      });
      g.selectAll('line').each(function(d){
        d.origDistance == null && (d.origDistance = d.distance);
        return d.distance *= (d.source.feature.scale + d.target.feature.scale) * 2 / 3;
      });
      return flip$(setTimeout)(1000, function(){
        return force.charge(function(it){
          return -it.feature.properties.area * it.scale;
        }).alpha(0.1);
      });
    });
  });
};
function curry$(f, args){
  return f.length > 1 ? function(){
    var params = args ? args.concat() : [];
    return params.push.apply(params, arguments) < f.length && arguments.length ?
      curry$.call(this, f, params) : f.apply(this, params);
  } : f;
}
function flip$(f){
  return curry$(function (x, y) { return f(y, x); });
}