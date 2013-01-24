(function(){
  $(document).ready(function(){
    return Geograph.fromjson('twCounty1982.topojson', {
      container: 'body'
    }, function(graph){
      return setTimeout(function(){
        graph.use(Layout.dorling);
        graph.layout.force.on('tick', function(e){
          var n, a, i$, len$, i, it, j$, len1$, j, jt, r, d, dx, dy;
          n = graph.blocks;
          a = graph.layout.force.alpha();
          for (i$ = 0, len$ = n.length; i$ < len$; ++i$) {
            i = i$;
            it = n[i$];
            for (j$ = 0, len1$ = n.length; j$ < len1$; ++j$) {
              j = j$;
              jt = n[j$];
              if (i === j) {
                continue;
              }
              r = it.feature.r + jt.feature.r;
              d = Math.sqrt(Math.pow(it.feature.t[0] - jt.feature.t[0] + (0.1 - a) * (it.x - jt.x), 2) + Math.pow(it.feature.t[1] - jt.feature.t[1] + (0.1 - a) * (it.y - jt.y), 2));
              if (r > d) {
                d = (d - r) / d * 12;
                dx = (it.feature.t[0] - jt.feature.t[0] + (0.1 - a) * (it.x - jt.x)) * d;
                dy = (it.feature.t[1] - jt.feature.t[1] + (0.1 - a) * (it.y - jt.y)) * d;
                it.x = it.x - dx;
                it.y = it.y - dy;
                jt.x = jt.x + dx;
                jt.y = jt.y + dy;
              }
            }
          }
          return graph.path.attr('transform', function(it){
            var x, y;
            x = it.feature.t[0] + 180 + (0.1 - a) * it.x;
            y = it.feature.t[1] + 230 + (0.1 - a) * it.y;
            return "translate(" + x + " " + y + ")";
          });
        });
        graph.transition(graph.path.transition().duration(750));
        setTimeout(function(){
          return graph.layout.force.start();
        }, 750);
        setTimeout(function(){
          graph.layout.force.stop();
          graph.use(Layout.flat);
          return graph.transition(graph.path.transition().duration(750));
        }, 4000);
        return setTimeout(function(){
          graph.use(Layout.cartogram);
          return graph.transition(graph.path.transition().duration(750));
        }, 6000);
      }, 1000);
    });
  });
}).call(this);
