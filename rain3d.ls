smallscale = [ 1 2 6 10 15 20 30 40 50 70 90 110 130 150 200 300 ]
bigscale = [10 20 60 100 150 200 300 400 500 600 700 800 900 1000 1200 1500]

changescale = (scale) ->
  d3.scale.quantile!
  .domain(scale)
  .range <[ #c5bec2 #99feff #00ccfc #0795fd #025ffe #3c9700 #2bfe00 #fdfe00 #ffcb00 #eaa200 #f30500 #d60002 #9e0003 #9e009d #d400d1 #fa00ff #facefb]>

rainscale = changescale bigscale

stations <- d3.json "stations.json"

root = new Firebase "https://cwbtw.firebaseio.com"
current = root.child "rainfall/2013-07-13/23:50:00"

rain-today = {}

countiestopo <- d3.json "twCounty2010.topo.json"

proj = mtw!

counties = topojson.feature countiestopo, countiestopo.objects['twCounty2010.geo']

path = d3.geo.path!projection proj
extent =  path.bounds counties

regions = d3.geom.voronoi!clip-extent(extent) [proj [+it.longitude, +it.latitude, it.name] for it in stations]

current.on \value ->
#  {time, data} = it.val!
  time = it.name!
  data = it.val!
  d3.select \#time
    .text time
  rain-today := data
  today = [parsed for name, {today} of data when parsed = parseFloat today]
  meshes = addGeoObject world, regions

  <- setTimeout _, 1000ms
  <- setInterval _, 50ms
  for [mesh, amount, fraction]:m in meshes
    setscale mesh, amount, fraction
    m.2 += (1-fraction)/50

var world

setscale = (mesh, amount, scale) ->
  mesh.scale.z = scale
  mesh.position.y = amount * scale

addGeoObject = (scene, features) ->
  meshes = []
  for geoFeature, i in features
    mesh = $d3g.transformSVGPath "M#{ geoFeature.join \L }Z"
    today = +rain-today[stations[i].name]?today
    color = new THREE.Color rainscale today .getHex!
    material = new THREE.MeshLambertMaterial { color }
    amount = today * 0.3
    simpleShapes = mesh.toShapes(false)
    for simpleShape in simpleShapes
      try
        shape3d = simpleShape.extrude { amount, -bevelEnabled }
        shape3d.boundingSphere = {radius: 3 * 100}
        toAdd = new THREE.Mesh shape3d, material
          ..rotation.x = Math.PI / 2
          ..translateY amount
          ..translateX -window.innerWidth/4
          ..translateZ -window.innerHeight/2
        scene.add toAdd
        meshes.push [toAdd, amount, 1/amount]
        setscale toAdd, amount, 1/amount
      catch e
        console.log e
  meshes

init3d = ->
    world := tQuery.createWorld {-webGLNeeded}
    $ \#nowebgl .show! unless tQuery.World.hasWebGL!
    cam = world.tCamera!
    cam.near = 20.0
    cam.updateProjectionMatrix!

    world.boilerplate!start!
    world.getCameraControls!
      ..rangeY = 3000
      ..rangeX = -2000
    cam.position.set 0 1000  600
    plane = new THREE.Mesh (new THREE.PlaneGeometry 1000, 1000, 20, 20), new THREE.MeshBasicMaterial {color: 5592405, +wireframe }
    plane.rotation.x = -Math.PI / 2
    world.add plane
    ambientLight = new THREE.AmbientLight 6316128
    world.add ambientLight

    directionalLight = new THREE.DirectionalLight 16777215
    directionalLight.position.set 1, 0.75, 0.5 .normalize!
    world.add directionalLight

<- $
init3d!
