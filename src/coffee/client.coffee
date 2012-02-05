if window['WebSocket']
  
  PIXEL_SIZE = 5

  $(document).ready ->
    server = null

    canvas = $('#game')
    context = canvas.get(0).getContext('2d')

    # Game data

    gameWorld = null
    gamePlayers = []
    gameId = null

    # Cache

    cWidth = 0
    cHeight = 0
    
    sendDirection = (direction) ->
      server.emit('action.direction', direction)

    connect = ->
      server = io.connect(host, { 'port': parseInt(port) })

      server.on 'connect', ->

        server.on 'game.step', (data) ->
          gamePlayers = data.players

        server.on 'game.init', (data) ->
          gameWorld = data.world
          window.world = data.world
          gameId = data.id
      
    connect()
    
    $(document).keydown (event) ->
      return unless server
      key = if event.keyCode then event.keyCode else event.which
      switch key
        when 37 then sendDirection 'left'
        when 38 then sendDirection 'up'
        when 39 then sendDirection 'right'
        when 40 then sendDirection 'down'

    # Drawing

    redraw = ->
      # Clear rect
      context.fillStyle = 'rgb(0,0,0)'
      context.fillRect(0,0,context.canvas.width,context.canvas.height)

      @player = getPlayer()
      return unless @player

      # Set clipping

      @realPlayerX = parseInt(cWidth / 2)
      @realPlayerY = parseInt(cHeight / 2)

      @clippingX = player.x - parseInt(cWidth / (2 * PIXEL_SIZE))
      @clippingY = player.y - parseInt(cHeight / (2 * PIXEL_SIZE))

      @clippingWidth = parseInt(cWidth / PIXEL_SIZE)
      @clippingHeight = parseInt(cHeight / PIXEL_SIZE)

      drawMap()
      drawPlayer()

    drawPlayer =  ->
      context.fillStyle = 'rgb(255,0,0)'
      context.fillRect(@realPlayerX, @realPlayerY, PIXEL_SIZE, PIXEL_SIZE)
    
    drawMap = ->
      context.fillStyle = 'rgb(255,255,255)'
      realX = 0

      for w in [clippingX..(clippingX + clippingWidth)]
        realY = 0
        for h in [clippingY..(clippingY + clippingHeight)]
          unless w < 0 or h < 0 or w > (gameWorld.length - 1) or h > (gameWorld[0].length - 1)
            if gameWorld[w][h] == 1
              context.fillRect(realX,realY,PIXEL_SIZE, PIXEL_SIZE)
          
          realY += PIXEL_SIZE
        realX += PIXEL_SIZE



    
    
    resize = ->
      context.canvas.width = window.innerWidth
      context.canvas.height = window.innerHeight - 140
      cWidth = context.canvas.width
      cHeight = context.canvas.height
      redraw()

    $(window).resize resize

    draw = ->
      redraw()

      window.setTimeout ->
        draw()
      , 33

    # Util

    getPlayer = ->
      for player in gamePlayers
        return player if player.id == gameId
      
      return null

    # Init

    resize()
    draw()
            
else
  alert 'Your browser does not support websockets.'

