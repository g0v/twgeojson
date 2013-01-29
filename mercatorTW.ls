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
