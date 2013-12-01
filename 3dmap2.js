var theCenter, proj, path, ramp, calculateBBoxSum, addGeoObject, init3d;
theCenter = {
  x: 300,
  y: 250
};
proj = mtw().scale(5000);
path = d3.geo.path().projection(proj);
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
addGeoObject = function(scene, features){
  var i$, len$, geoFeature, lresult$, name, coords, mesh, rgb, color, ref$, material, amount, simpleShapes, simpleShapesCCW, j$, len1$, simpleShape, shape3d, x$, toAdd, e, results$ = [];
  for (i$ = 0, len$ = features.length; i$ < len$; ++i$) {
    geoFeature = features[i$];
    lresult$ = [];
    name = geoFeature.properties.name;
    if (true || false) {
      coords = geoFeature.geometry.coordinates;
      coords = G0V.TOPOJSON.util.filterOutZeroArea(coords);
      coords = G0V.TOPOJSON.util.filterOutRepeatedPoints(coords);
      geoFeature.geometry.coordinates = coords;
      mesh = $d3g.transformSVGPath(path(geoFeature));
      rgb = d3.rgb(ramp(Math.random() * 255));
      color = (ref$ = new THREE.Color()).setRGB.apply(ref$, [rgb['r'], rgb['g'], rgb['b']]).getHex();
      material = new THREE.MeshLambertMaterial({
        color: color
      });
      amount = parseInt(Math.random() * 50);
      simpleShapes = mesh.toShapes(false);
      simpleShapesCCW = mesh.toShapes(true);
      simpleShapes = simpleShapesCCW;
      for (j$ = 0, len1$ = simpleShapes.length; j$ < len1$; ++j$) {
        simpleShape = simpleShapes[j$];
        try {
          shape3d = simpleShape.extrude({
            amount: amount,
            bevelEnabled: false
          });
          x$ = toAdd = new THREE.Mesh(shape3d, material);
          x$.rotation.x = Math.PI;
          x$.translateZ(-amount - 1);
          x$.translateX(-theCenter.x);
          x$.translateY(-theCenter.y);
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
  cam.position.set(0, 0, 800);
  return d3.json("twCounty2010.topo.json", function(tw){
    var twtopo, data, plane, ambientLight, directionalLight;
    twtopo = topojson.feature(tw, tw.objects['twCounty2010.geo']);
    data = twtopo.features;
    plane = new THREE.Mesh(new THREE.PlaneGeometry(640, 640, 20, 20), new THREE.MeshBasicMaterial({
      color: 0x505050,
      wireframe: true
    }));
    plane.rotation.x = Math.PI;
    world.add(plane);
    ambientLight = new THREE.AmbientLight(0x606060);
    world.add(ambientLight);
    directionalLight = new THREE.DirectionalLight(0xffffff);
    directionalLight.position.set(0.5, 0.5, 1.0).normalize();
    world.add(directionalLight);
    return addGeoObject(world, data);
  });
};