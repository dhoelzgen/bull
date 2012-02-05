module.exports = class
  constructor: (@width, @height) ->
    @world = []

    randomHeight = 200
    randomLow = 400

    for w in [0..width-1]
      @world[w] = []
      
      r = Math.random()
      s = Math.random()

      if r < 0.3
        randomHeight -= 1
      else if r > 0.7
        randomHeight += 1

      if s < 0.3
        randomLow -= 1
      else if s > 0.7
        randomLow += 1

      for h in [0..height-1]
        if h < randomHeight
          @world[w][h] = 1
        else if h > randomLow
          @world[w][h] = 1
        else
          @world[w][h] = 0

  data: ->
    return @world

  get: (x, y) ->
    return 1 if x < 0 or y < 0 or x > (@width - 1) or y > (@height - 1)
    return @world[x][y]

  nextSpawnPoint: ->
    x = parseInt(Math.random() * @width)
    y = 0

    while @world[x][y] isnt 0
      y += 1

    y += 20

    return { x: x, y: y }
