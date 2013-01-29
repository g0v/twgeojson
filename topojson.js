var color, Layout, Geograph, Geoblock, slice$ = [].slice;
color = d3.scale.category20c();
Layout = (function(){
  Layout.displayName = 'Layout';
  var prototype = Layout.prototype, constructor = Layout;
  prototype.name = "default";
  prototype.features = [];
  prototype.path = function(){};
  prototype.transform = function(){};
  Layout.proj = mercatorTW().call;
  Layout.carto = d3.cartogram().projection(Layout.proj);
  Layout.flat = (function(superclass){
    var prototype = extend$((import$(flat, superclass).displayName = 'flat', flat), superclass).prototype, constructor = flat;
    flat.name = "flat";
    function flat(topo, geom, graph){
      this.features = Layout.carto.features(topo, geom);
    }
    prototype.path = function(){
      return d3.geo.path().projection(Layout.proj)(this.feature);
    };
    prototype.transform = function(){
      return "translate(0 100)";
    };
    return flat;
  }(Layout));
  Layout.cartogram = (function(superclass){
    var prototype = extend$((import$(cartogram, superclass).displayName = 'cartogram', cartogram), superclass).prototype, constructor = cartogram;
    cartogram.name = "carto";
    function cartogram(topo, geom, graph){
      this.features = Layout.carto(topo, geom).features;
    }
    prototype.path = function(){
      return Layout.carto.path(this.feature);
    };
    prototype.transform = function(){
      return "translate(0 100)";
    };
    return cartogram;
  }(Layout));
  Layout.dorling = (function(superclass){
    var prototype = extend$((import$(dorling, superclass).displayName = 'dorling', dorling), superclass).prototype, constructor = dorling;
    dorling.name = "dorling";
    function dorling(topo, geom, graph){
      var features, lens, res$, i$, len$, feature, x, o, z, avg, center, rad, fx, i, lresult$, ref$, angle, ret, res1$, j$, len1$, f, radius, pt, links, a, j, b, block, fn$ = curry$(function(x$, y$){
        return x$.concat(y$);
      }), fn1$ = curry$(function(x$, y$){
        return x$.concat(y$);
      });
      features = Layout.carto.features(topo, geom);
      res$ = [];
      for (i$ = 0, len$ = features.length; i$ < len$; ++i$) {
        feature = features[i$];
        res$.push(d3.geo.path().projection(Layout.proj)(feature).split(/[ML]/).length);
      }
      lens = res$;
      lens = (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = features).length; i$ < len$; ++i$) {
          feature = ref$[i$];
          results$.push(d3.geo.path().projection(Layout.proj)(feature).split(/M/));
        }
        return results$;
      }()).map(function(it){
        return it.map(function(it){
          return it.split(/L/);
        });
      }).map(function(it){
        return it.sort(function(a, b){
          return b.length - a.length;
        });
      }).map(function(it){
        return it[0].length;
      });
      res$ = [];
      for (i$ = 0, len$ = lens.length; i$ < len$; ++i$) {
        x = lens[i$];
        res$.push(x - 1);
      }
      lens = res$;
      res$ = [];
      for (i$ = 0, len$ = features.length; i$ < len$; ++i$) {
        o = features[i$];
        res$.push(o.geometry.coordinates.reduce(fn$));
      }
      features = res$;
      res$ = [];
      for (i$ = 0, len$ = features.length; i$ < len$; ++i$) {
        feature = features[i$];
        if (typeof feature[0][0] === typeof 0.0) {
          res$.push(feature);
        } else {
          res$.push(feature.reduce(fn1$));
        }
      }
      features = res$;
      z = 180;
      res$ = [];
      for (i$ = 0, len$ = features.length; i$ < len$; ++i$) {
        feature = features[i$];
        res$.push(feature.reduce(fn2$, [0, 0]).map((fn3$)));
      }
      avg = res$;
      center = avg.reduce(function(a, b){
        return [a[0] + b[0], a[1] + b[1]];
      }, [0, 0]).map((function(it){
        return it / avg.length;
      }));
      rad = [];
      res$ = [];
      for (i$ = 0, len$ = features.length; i$ < len$; ++i$) {
        i = i$;
        feature = features[i$];
        lresult$ = [];
        ref$ = [0, ""], angle = ref$[0], ret = ref$[1];
        res1$ = [];
        for (j$ = 0, len1$ = feature.length; j$ < len1$; ++j$) {
          f = feature[j$];
          res1$.push([(f[0] - avg[i][0]) * z, (f[1] - avg[i][1]) * z]);
        }
        feature = res1$;
        radius = feature.reduce(fn4$, 0) / feature.length;
        rad.push(radius);
        lresult$.push(f = (fn5$()));
        res$.push(lresult$);
      }
      fx = res$;
      res$ = [];
      for (i$ = 0, len$ = fx.length; i$ < len$; ++i$) {
        i = i$;
        f = fx[i$];
        res$.push({
          f: f[0],
          z: z,
          r: rad[i],
          t: [(avg[i][0] - center[0]) * z, (-avg[i][1] + center[1]) * z]
        });
      }
      this.features = res$;
      links = [];
      for (i$ = 0, len$ = avg.length; i$ < len$; ++i$) {
        i = i$;
        a = avg[i$];
        for (j$ = 0, len1$ = avg.length; j$ < len1$; ++j$) {
          j = j$;
          b = avg[j$];
          if (i === j) {
            continue;
          }
          if (rad[i] + rad[j] > z * Math.sqrt(Math.pow(avg[i][0] - avg[j][0], 2) + Math.pow(avg[i][1] - avg[j][1], 2))) {
            links.push({
              source: i,
              target: j,
              weight: rad[i] + rad[j]
            });
          }
        }
      }
      for (i$ = 0, len$ = (ref$ = graph.blocks).length; i$ < len$; ++i$) {
        i = i$;
        block = ref$[i$];
        block.x = 0;
        block.y = 0;
        block.weight = rad[i];
      }
      this.force = d3.layout.force().charge(0).gravity(0.9).friction(1.0).size([700, 700]);
      this.force.nodes(graph.blocks);
      function fn2$(a, b){
        return [a[0] + b[0], a[1] + b[1]];
      }
      function fn3$(it){
        return it / feature.length;
      }
      function fn4$(a, b){
        return a + Math.sqrt(Math.pow(b[0], 2) + Math.pow(b[1], 2));
      }
      function fn5$(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = slice$.call(feature, 0, lens[i] + 1 || 9e9)).length; i$ < len$; ++i$) {
          pt = ref$[i$];
          angle += 6.28318 / (lens[i] - 1);
          results$.push([Math.cos(angle) * radius, Math.sin(angle) * radius]);
        }
        return results$;
      }
    }
    prototype.path = function(){
      var i, x, y;
      return (function(){
        var i$, ref$, len$, ref1$, results$ = [];
        for (i$ = 0, len$ = (ref$ = this.feature.f).length; i$ < len$; ++i$) {
          i = i$;
          ref1$ = ref$[i$], x = ref1$[0], y = ref1$[1];
          results$.push(((i === 0 && 'M') || 'L') + "" + x + " " + y);
        }
        return results$;
      }.call(this)).join(" ");
    };
    prototype.transform = function(){
      var f;
      f = this.feature;
      return "translate(" + (f.t[0] + 180) + " " + (f.t[1] + 230) + ")";
    };
    return dorling;
  }(Layout));
  function Layout(){}
  return Layout;
}());
Geograph = (function(){
  Geograph.displayName = 'Geograph';
  var prototype = Geograph.prototype, constructor = Geograph;
  Geograph.fromjson = function(filename, config, callback){
    return d3.json(filename, function(data){
      return callback(new Geograph(data, config));
    });
  };
  function Geograph(topo, config){
    var i$, ref$, len$, i, feature, b, this$ = this;
    this.x = 0;
    this.y = 0;
    import$(this, config);
    this.topo = topo;
    this.geom = topo.objects.twCounty1982.geometries;
    this.layouts = {};
    this.blocks = new Array(this.geom.length);
    this.use(Layout.flat);
    for (i$ = 0, len$ = (ref$ = this.layout.features).length; i$ < len$; ++i$) {
      i = i$;
      feature = ref$[i$];
      this.blocks[i] = new Geoblock(this, feature);
    }
    this.avg = (function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = this.blocks).length; i$ < len$; ++i$) {
        b = ref$[i$];
        results$.push(b.avg);
      }
      return results$;
    }.call(this)).reduce(function(a, b){
      return [a[0] + b[0], a[1] + b[1]];
    }).map(function(it){
      return it / this$.blocks.length;
    });
    this.svg = d3.select(this.container).append('svg').attr('width', $('body').width() * 0.9).attr('height', $('body').height() * 0.9).style('margin', $('body').height() * 0.05 + " 0 0 " + $('body').width() * 0.05).attr('viewBox', "0 0 1024 768").attr('preserveAspectRatio', "xMinYMin meet");
    this.group = this.svg.append('g');
    this.path = this.group.selectAll('path').data(this.blocks).enter().append('path').attr('stroke-width', '1px').attr('stroke', '#000').attr('fill', function(it, i){
      return color(i % 20);
    }).attr('d', function(it){
      return this$.layout.path.call(it);
    }).attr('transform', function(it){
      return this$.layout.transform.call(it);
    });
  }
  prototype.transition = function(it, t){
    var this$ = this;
    t == null && (t = true);
    return it.attr('d', function(it){
      return this$.layout.path.call(it);
    }).attr('transform', function(it){
      return this$.layout.transform.call(it);
    });
  };
  prototype.use = function(lo){
    var i$, ref$, len$, i, feature, ref1$, results$ = [];
    if (!this.layouts[lo.name]) {
      this.layout = new lo(this.topo, this.geom, this);
      this.layouts[lo.name] = this.layout;
    } else {
      this.layout = this.layouts[lo.name];
    }
    for (i$ = 0, len$ = (ref$ = this.layout.features).length; i$ < len$; ++i$) {
      i = i$;
      feature = ref$[i$];
      results$.push((ref1$ = this.blocks[i]) != null ? ref1$.feature = feature : void 8);
    }
    return results$;
  };
  return Geograph;
}());
Geoblock = (function(){
  Geoblock.displayName = 'Geoblock';
  var prototype = Geoblock.prototype, constructor = Geoblock;
  function Geoblock(parent, feature){
    var plys, _plys, pj, res$, i$, len$, ply, pt, this$ = this;
    this.feature = feature;
    plys = feature.geometry.coordinates;
    if (feature.geometry.type === "MultiPolygon") {
      plys = plys.reduce(curry$(function(x$, y$){
        return x$.concat(y$);
      }));
    }
    this.avg = (_plys = plys.reduce(curry$(function(x$, y$){
      return x$.concat(y$);
    }))).reduce(function(a, b){
      return [a[0] + b[0], a[1] + b[1]];
    }).map((function(it){
      return it / _plys.length;
    }));
    pj = function(it){
      return [it[0] - this$.avg[0], -(it[1] - this$.avg[1])];
    };
    res$ = [];
    for (i$ = 0, len$ = plys.length; i$ < len$; ++i$) {
      ply = plys[i$];
      res$.push([(fn$())][0]);
    }
    this.pts2d = res$;
    function fn$(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = ply).length; i$ < len$; ++i$) {
        pt = ref$[i$];
        results$.push(pj(
        [pt[0], pt[1]]));
      }
      return results$;
    }
  }
  return Geoblock;
}());
this.Geograph = Geograph;
this.Geoblock = Geoblock;
this.Layout = Layout;
function extend$(sub, sup){
  function fun(){} fun.prototype = (sub.superclass = sup).prototype;
  (sub.prototype = new fun).constructor = sub;
  if (typeof sup.extended == 'function') sup.extended(sub);
  return sub;
}
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
function curry$(f, args){
  return f.length > 1 ? function(){
    var params = args ? args.concat() : [];
    return params.push.apply(params, arguments) < f.length && arguments.length ?
      curry$.call(this, f, params) : f.apply(this, params);
  } : f;
}