BLOCK_HITPOINTS = 1
TEMP_HITPOINTS = 137612537

module.exports = class
  constructor: (@width, @height) ->
    @world = []
    @changelist = []

    # Init world

    for w in [0..@width-1]
      @world[w] = []
      for h in [0..@height-1]
        @world[w][h] = 0

    # Obstacles

    for i in [1..300]
      oX = parseInt(Math.random() * @width) 
      oY = parseInt(Math.random() * @height)
      eX = parseInt(Math.random() * 40)  + 60 + oX
      eY = parseInt(Math.random() * 40) + 60 + oY

      oX = 0 if oX < 0
      oY = 0 if oY < 0
      eX = @width - 1 if eX > @width - 1
      eY = @height - 1 if eY > @height - 1

      for w in [oX..eX]
        for h in [oY..eY]
          @world[w][h] = TEMP_HITPOINTS unless @world[w][h] == BLOCK_HITPOINTS

      # Make obstacle's surface look more natural

      randomHigh = eY - 20
      randomLow =  oY + 20

      for w in [oX..eX]
        r = Math.random()
        s = Math.random()

        if r < 0.3
          randomHigh -= 1
        else if r > 0.7
          randomHigh += 1

        if s < 0.3
          randomLow -= 1
        else if s > 0.7
          randomLow += 1
          
        for h in [oY..eY]
          if @world[w][h] == TEMP_HITPOINTS
            if h > randomHigh
              @world[w][h] = 0
            else if h < randomLow
              @world[w][h] = 0

      randomHigh = eX - 20
      randomLow =  oX + 20

      for h in [oY..eY]
        r = Math.random()
        s = Math.random()

        if r < 0.3
          randomHigh -= 1
        else if r > 0.7
          randomHigh += 1

        if s < 0.3
          randomLow -= 1
        else if s > 0.7
          randomLow += 1
          
        for w in [oX..eX]
          if @world[w][h] == TEMP_HITPOINTS
            if w > randomHigh
              @world[w][h] = 0
            else if w < randomLow
              @world[w][h] = 0

      for w in [oX..eX]
        for h in [oY..eY]
          @world[w][h] = BLOCK_HITPOINTS if @world[w][h] == TEMP_HITPOINTS

    # Top and bottom

    randomHigh = 200
    randomLow = @height - 200

    for w in [0..@width-1]
      
      r = Math.random()
      s = Math.random()

      if r < 0.3
        randomHigh -= 1
      else if r > 0.7
        randomHigh += 1

      if s < 0.3
        randomLow -= 1
      else if s > 0.7
        randomLow += 1

      for h in [0..@height-1] 
        if h < randomHigh
          @world[w][h] = BLOCK_HITPOINTS
        else if h > randomLow
          @world[w][h] = BLOCK_HITPOINTS

    # Left an right

    randomHigh = 200
    randomLow = @width - 200

    for h in [0..@height-1]
      
      r = Math.random()
      s = Math.random()

      if r < 0.3
        randomHigh -= 1
      else if r > 0.7
        randomHigh += 1

      if s < 0.3
        randomLow -= 1
      else if s > 0.7
        randomLow += 1

      for w in [0..@width-1]
        if w < randomHigh
          @world[w][h] = BLOCK_HITPOINTS
        else if w > randomLow
          @world[w][h] = BLOCK_HITPOINTS


  data: ->
    return @world

  
  get: (x, y) ->
    return 1 if x < 0 or y < 0 or x > (@width - 1) or y > (@height - 1)
    return @world[x][y]

  hit: (x, y) ->
    return if x < 0 or y < 0 or x > (@width - 1) or y > (@height - 1)

    if @world[x][y] > 0
      @world[x][y] -= 1

      if @world[x][y] == 0
        @world[x][y] = 0
        @changelist.push { x: x, y: y }

  resetChangeList: ->
    @changelist = []

  nextSpawnPoint: ->
    free = false
    
    x = 0
    y = 0

    while free isnt true
      x = parseInt(Math.random() * @width)
      y = parseInt(Math.random() * @height)
      
      free = true

      for i in [-2..2]
        for j in [-2..2]
          free = false if @.get(x + i, y + j) > 0

    return [x, y]
