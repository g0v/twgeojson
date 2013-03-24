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

calculateBBoxSum = (shapes, debugName, debugCW ) ->
    sum = 0;
    if shapes.length
        for shape in shapes
            try
                geometry = shape.makeGeometry!
                bbox = geometry.shapebb;
                sum += (Math.abs(bbox.maxY - bbox.minY)+1) * (Math.abs(bbox.maxX - bbox.minX)+1)
            catch e
                console.log "exception in calculateBBoxSum\n"
                console.log e
                console.log shape
        if not sum
            console.log "Zero sum #debugName #debugCW\n"
            console.log shapes

    sum

addGeoObject = (scene, data) ->
    for geoFeature in data.features
      name = geoFeature.properties.name
      if true or
         (name == '台北縣') or
         (name == '基隆市') or
         (name == '台北市') or
         (name == '桃園縣') or
         (name == '新竹縣') or
         (name == '苗栗縣') or
         (name == '台中縣') or
         (name == '台中市') or
         (name == '彰化縣') or
         (name == '雲林縣') or
         (name == '嘉義縣') or
         (name == '嘉義市') or
         (name == '台南縣') or
         (name == '台南市') or
         (name == '高雄縣') or
         (name == '高雄市') or
         (name == '屏東縣') or
         false

        #console.log \path path
        #console.log \path \geoFeature
        #console.log path geoFeature
        mesh = $d3g.transformSVGPath path geoFeature
        #console.log \mesh
        #console.log mesh
        rgb = d3.rgb ramp Math.random! * 255
        color = new THREE.Color!setRGB ...rgb<[r g b]> .getHex!
        material = new THREE.MeshLambertMaterial { color }
        amount = parseInt Math.random! * 100
        do
            simpleShapes = mesh.toShapes(false)
            simpleShapesCCW = mesh.toShapes(true)
            area = calculateBBoxSum simpleShapes, name, \CW
            areaCCW = calculateBBoxSum simpleShapesCCW, name, \CCW

            if ( areaCCW < area )
                console.log "CW #name\n"

            simpleShapes = simpleShapesCCW

            #console.log \simpleShapes
            #console.log simpleShapes
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
              catch e
                console.log "error in extrude #name. Ignored.\n"
                console.log e
                console.log simpleShape


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
    #data <- d3.json "test.json"
#    data.features = [ f for f in data.features when f.properties.name is /台北縣/]
    console.log \hi_data data
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
