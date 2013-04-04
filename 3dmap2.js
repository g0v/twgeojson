var mercator, mercatorTW, projection, path, ramp, calculateBBoxSum, addGeoObject, init3d, slice$ = [].slice;
geo.setupGeo();
mercator = (function(){
  mercator.displayName = 'mercator';
  var prototype = mercator.prototype, constructor = mercator;
  function mercator(arg$){
    var this$ = this instanceof ctor$ ? this : new ctor$;
    if (arg$ != null) {
      this$.scale = arg$.scale, this$.translate = arg$.translate;
    }
    this$.call2 = bind$(this$, 'call2', prototype);
    this$.m = d3.geo.mercator();
    if (this$.scale) {
      this$.m.scale(this$.scale);
    }
    if (this$.translate) {
      this$.m.translate(this$.translate);
    }
    return this$;
  } function ctor$(){} ctor$.prototype = prototype;
  prototype.call2 = function(){
    var args;
    args = slice$.call(arguments);
    return this.m.apply(this, args);
  };
  return mercator;
}());
mercatorTW = (function(superclass){
  var prototype = extend$((import$(mercatorTW, superclass).displayName = 'mercatorTW', mercatorTW), superclass).prototype, constructor = mercatorTW;
  function mercatorTW(arg$){
    var ref$, ref1$, this$ = this instanceof ctor$ ? this : new ctor$;
    ref$ = arg$ != null
      ? arg$
      : {}, this$.scale = (ref1$ = ref$.scale) != null ? ref1$ : 50000, this$.translate = (ref1$ = ref$.translate) != null
      ? ref1$
      : [-16550, 3700];
    this$.call = bind$(this$, 'call', prototype);
    this$.call2 = bind$(this$, 'call2', prototype);
    mercatorTW.superclass.apply(this$, arguments);
    return this$;
  } function ctor$(){} ctor$.prototype = prototype;
  prototype.call2 = function(arg$){
    var x, y;
    x = arg$[0], y = arg$[1];
    return console.log('call2');
  };
  prototype.call = function(arg$){
    var x, y;
    x = arg$[0], y = arg$[1];
    if (x < 118.5) {
      x += 1.3;
    }
    if (y > 25.8) {
      x -= 0.2;
      y -= 1;
    }
    return this.m([x, y]);
  };
  return mercatorTW;
}(mercator));
projection = mercatorTW().call;
path = d3.geo.path().projection(projection);
ramp = d3.scale.linear().domain([0, 255]).range(["red", "green"]);
calculateBBoxSum = function(shapes, debugName, debugCW){
  var sum, i$, len$, shape, geometry, bbox, e;
  sum = 0;
  if (shapes.length) {
    for (i$ = 0, len$ = shapes.length; i$ < len$; ++i$) {
      shape = shapes[i$];
      try {
        geometry = shape.makeGeometry();
        bbox = geometry.shapebb;
        sum += (Math.abs(bbox.maxY - bbox.minY) + 1) * (Math.abs(bbox.maxX - bbox.minX) + 1);
      } catch (e$) {
        e = e$;
        console.log("exception in calculateBBoxSum\n");
        console.log(e);
        console.log(shape);
      }
    }
    if (!sum) {
      console.log("Zero sum " + debugName + " " + debugCW + "\n");
      console.log(shapes);
    }
  }
  return sum;
};
addGeoObject = function(scene, data){
  var i$, ref$, len$, geoFeature, lresult$, name, mesh, rgb, color, ref1$, material, amount, simpleShapes, simpleShapesCCW, area, areaCCW, j$, len1$, simpleShape, shape3d, x$, toAdd, e, results$ = [];
  for (i$ = 0, len$ = (ref$ = data.features).length; i$ < len$; ++i$) {
    geoFeature = ref$[i$];
    lresult$ = [];
    name = geoFeature.properties.name;
    if (true || name === '台北縣' || name === '基隆市' || name === '台北市' || name === '桃園縣' || name === '新竹縣' || name === '苗栗縣' || name === '台中縣' || name === '台中市' || name === '彰化縣' || name === '雲林縣' || name === '嘉義縣' || name === '嘉義市' || name === '台南縣' || name === '台南市' || name === '高雄縣' || name === '高雄市' || name === '屏東縣' || false) {
      mesh = $d3g.transformSVGPath(path(geoFeature));
      rgb = d3.rgb(ramp(Math.random() * 255));
      color = (ref1$ = new THREE.Color()).setRGB.apply(ref1$, [rgb['r'], rgb['g'], rgb['b']]).getHex();
      material = new THREE.MeshLambertMaterial({
        color: color
      });
      amount = parseInt(Math.random() * 100);
      simpleShapes = mesh.toShapes(false);
      simpleShapesCCW = mesh.toShapes(true);
      area = calculateBBoxSum(simpleShapes, name, 'CW');
      areaCCW = calculateBBoxSum(simpleShapesCCW, name, 'CCW');
      if (areaCCW < area) {
        console.log("CW " + name + "\n");
      }
      simpleShapes = simpleShapesCCW;
      for (j$ = 0, len1$ = simpleShapes.length; j$ < len1$; ++j$) {
        simpleShape = simpleShapes[j$];
        try {
          shape3d = simpleShape.extrude({
            amount: amount,
            bevelEnabled: false
          });
          shape3d.boundingSphere = {
            radius: 3 * 100
          };
          x$ = toAdd = new THREE.Mesh(shape3d, material);
          x$.rotation.x = Math.PI / 2;
          x$.translateY(amount);
          x$.translateX(-window.innerWidth / 4);
          x$.translateZ(-window.innerHeight / 2);
          lresult$.push(scene.add(toAdd));
        } catch (e$) {
          e = e$;
          console.log("error in extrude " + name + ". Ignored.\n");
          console.log(e);
          lresult$.push(console.log(simpleShape));
        }
      }
    }
    results$.push(lresult$);
  }
  return results$;
};
init3d = function(){
  var world, cam;
  world = tQuery.createWorld({
    webGLNeeded: false
  });
  if (!tQuery.World.hasWebGL()) {
    $(function(){
      return $('#nowebgl').show();
    });
  }
  cam = world.tCamera();
  cam.near = 20.0;
  cam.updateProjectionMatrix();
  console.log(cam.position);
  world.boilerplate().start();
  world.getCameraControls().rangeY = 3000;
  world.getCameraControls().rangeX = -2000;
  cam.position.set(0, 1000, 600);
  return d3.json("twCounty2010.json", function(data){
    var plane, ambientLight, directionalLight;
    console.log('hi_data', data);
    console.log(data.features);
    plane = new THREE.Mesh(new THREE.PlaneGeometry(1000, 1000, 20, 20), new THREE.MeshBasicMaterial({
      color: 5592405,
      wireframe: true
    }));
    plane.rotation.x = -Math.PI / 2;
    world.add(plane);
    ambientLight = new THREE.AmbientLight(6316128);
    world.add(ambientLight);
    directionalLight = new THREE.DirectionalLight(16777215);
    directionalLight.position.set(1, 0.75, 0.5).normalize();
    world.add(directionalLight);
    return addGeoObject(world, data);
  });
};
function bind$(obj, key, target){
  return function(){ return (target || obj)[key].apply(obj, arguments) };
}
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