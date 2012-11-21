geo.setupGeo!

class mercator
    ({@scale, @translate}?) ~>
        @m = d3.geo.mercator!
        @m.scale @scale if @scale
        @m.translate @translate if @translate

    call2: (...args) ~>
        @m(...args)

class mercatorTW extends mercator
    ({@scale = 50000, @translate = [-16550, 3700]} = {}) ~>
        super ...

    call2: ([x,y]) ~>
        console.log \call2
    call: ([x,y]) ~>
        if x < 118.5
            x += 1.3
        if y > 25.8
            x -= 0.2
            y -= 1
        @m [x,y]


projection = mercatorTW!call
#projection = d3.geo.mercator!scale 50000 .translate [-16400 3800]
path = d3.geo.path!projection projection

ramp=d3.scale.linear().domain([0,255]).range(["red","green"]);

addGeoObject = (scene, data) ->
    for geoFeature in data.features
      mesh = $d3g.transformSVGPath path geoFeature
      rgb = d3.rgb ramp Math.random! * 255
      color = new THREE.Color!setRGB ...rgb<[r g b]> .getHex!
      material = new THREE.MeshLambertMaterial { color }
      amount = parseInt Math.random! * 100
      do
        shape3d = mesh.extrude { amount, -bevelEnabled }
        shape3d.boundingSphere = {radius: 3 * 100};
        toAdd = new THREE.Mesh shape3d, material
          ..rotation.x = Math.PI / 2
          ..translateY amount
          ..translateX -window.innerWidth/4
          ..translateZ -window.innerHeight/2
        scene.add toAdd


init3d = ->
    world = tQuery.createWorld {-webGLNeeded}
    unless tQuery.World.hasWebGL!
        $ -> $ \#nowebgl .show! 
    console.log world.tCamera!position
    world.boilerplate!start!
    world.getCameraControls!rangeY = 3000
    world.getCameraControls!rangeX = -2000
    world.tCamera!position.set 0 1000  300
    data <- d3.json "twCounty1982.json"
#    data.features = [ f for f in data.features when f.properties.name is /台北縣/]
    console.log \hi data
    console.log data.features
    plane = new THREE.Mesh (new THREE.PlaneGeometry 1000, 1000, 20, 20), new THREE.MeshBasicMaterial {
      color: 5592405
      wireframe: true
    }
    plane.rotation.x = -Math.PI / 2
    world.add plane
    ambientLight = new THREE.AmbientLight 6316128
    world.add ambientLight

    directionalLight = new THREE.DirectionalLight 16777215
    (directionalLight.position.set 1, 0.75, 0.5).normalize!
    world.add directionalLight

    addGeoObject world, data
