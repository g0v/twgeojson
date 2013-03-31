mainland = d3.geo.conicEqualArea!
  .parallels [23.5, 24.5]
  .rotate [-121, 0]
  .center [0, 23.6]

mtw = ->
  mainland = d3.geo.conicEqualArea!
    .parallels [23.5, 24.5]
    .rotate [-123, 0]
    .center [0, 23.6]

  kme = d3.geo.conicEqualArea!
    .parallels [23.5, 24.5]
    .rotate [-121.7, 0]
    .center [0, 23.6]

  ljf = d3.geo.conicEqualArea!
    .parallels [23.5, 24.5]
    .rotate [-123.4, 0]
    .center [0, 24.6]

  projection = ([lon, lat]) -> switch
  | lon < 118.5 => kme
  | lat > 25.8  => ljf
  | otherwise   => mainland

  function mtw(coordinates)
    projection(coordinates)(coordinates);

  mtw.scale = (x) ->
    return mainland.scale! if !arguments.length
    mainland.scale x
    kme.scale x
    ljf.scale x
    mtw.translate mainland.translate!

  mtw.translate = ([dx, dy]:x) ->
    return mainland.translate! if !arguments.length
    dz = mainland.scale!
    mainland.translate x
    # XXX review this
    kme.translate x
    ljf.translate x
    mtw

  return mtw.scale 8000

class mercator
    ({@scale, @translate}?) ~>
        @m = d3.geo.mercator!
        @m.scale @scale if @scale
        @m.translate @translate if @translate

    call2: (...args) ~>
        @m(...args)

class mercatorTW extends mercator
    ({@scale = 50000, @translate = [-16550, 3560]} = {}) ~>
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
