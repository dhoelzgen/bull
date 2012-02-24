if window['WebSocket']
  
  PIXEL_SIZE = 5

  COLOR_SELF = '#3d700a'
  COLOR_ENEMY = '#498d05'
  COLOR_DEAD = '#253008'
  COLOR_BULLET = '#3d700a'
  COLOR_OBSTACLE = '#253008'
  COLOR_CLEAN = '#304818'

  $(document).ready ->
    server = null

    canvas = $('#game')
    context = canvas.get(0).getContext('2d')

    # Game data

    gameWorld = null
    gameBullets = null
    gamePlayers = []
    gameId = null

    # Cache

    cWidth = 0
    cHeight = 0
    
    sendMove = (direction) ->
      server.emit('action.move', direction)

    sendStop = (direction) ->
      server.emit('action.stop', direction)

    sendShoot = ->
      server.emit('action.shoot', null)

    sendStopShooting = ->
      server.emit('action.stopShooting', null)

    connect = ->
      server = io.connect(host, { 'port': parseInt(port) })

      server.on 'connect', ->

        server.on 'game.step', (data) ->
          gamePlayers = data.players
          gameBullets = data.bullets
          
          gameWorld[change.x][change.y] = 0 for change in data.changes

        server.on 'game.init', (data) ->
          gameWorld = data.world
          gameId = data.id
      
    connect()
    
    $(document).keydown (event) ->
      return unless server
      key = if event.keyCode then event.keyCode else event.which
      switch key
        when 37 then sendMove 'left'
        when 38 then sendMove 'up'
        when 39 then sendMove 'right'
        when 40 then sendMove 'down'
        when 32 then sendShoot()

    $(document).keyup (event) ->
      return unless server
      key = if event.keyCode then event.keyCode else event.which
      switch key
        when 37 then sendStop 'left'
        when 38 then sendStop 'up'
        when 39 then sendStop 'right'
        when 40 then sendStop 'down'
        when 32 then sendStopShooting()

    # Drawing

    redraw = ->
      # Clear rect
      context.fillStyle = COLOR_CLEAN
      context.fillRect(0,0,context.canvas.width,context.canvas.height)

      @controlled = getPlayer()
      return unless @controlled

      # Set clipping

      @relativeX = parseInt(cWidth / 2) - parseInt(cWidth / 2 % PIXEL_SIZE)
      @relativeY = parseInt(cHeight / 2) - parseInt(cHeight / 2 % PIXEL_SIZE)

      @clippingX = @controlled.x - parseInt(cWidth / (2 * PIXEL_SIZE))
      @clippingY = @controlled.y - parseInt(cHeight / (2 * PIXEL_SIZE))

      @clippingWidth = parseInt(cWidth / PIXEL_SIZE)
      @clippingHeight = parseInt(cHeight / PIXEL_SIZE)

      drawMap()
      drawPlayer(player) for player in gamePlayers
      drawBullets()

    drawPlayer = (player) ->

      if player.dead
        context.fillStyle = COLOR_DEAD
      else
        if player is @controlled
          context.fillStyle = COLOR_SELF
        else
          context.fillStyle = COLOR_ENEMY

      [player_x, player_y] = transformCoords(player.x, player.y)

      if player.x > @clippingX and player.x < (@clippingX + @clippingWidth) and player.y > @clippingY and player.y < (@clippingY + @clippingHeight)
        context.fillRect(player_x - PIXEL_SIZE, player_y  - PIXEL_SIZE, PIXEL_SIZE * 3 , PIXEL_SIZE * 3)

        # Draw fireing indicator
        if player.shooting
          if player.direction.shoot.up
            context.fillRect(player_x - PIXEL_SIZE, player_y  - PIXEL_SIZE * 3, PIXEL_SIZE * 3 , PIXEL_SIZE)
            context.fillRect(player_x, player_y  - PIXEL_SIZE * 4, PIXEL_SIZE, PIXEL_SIZE)
          else if player.direction.shoot.down
            context.fillRect(player_x - PIXEL_SIZE , player_y  + PIXEL_SIZE * 3, PIXEL_SIZE * 3 , PIXEL_SIZE)
            context.fillRect(player_x, player_y  + PIXEL_SIZE * 4, PIXEL_SIZE, PIXEL_SIZE)
          else if player.direction.shoot.left
            context.fillRect(player_x - PIXEL_SIZE * 3, player_y - PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE * 3)
            context.fillRect(player_x - PIXEL_SIZE * 4, player_y, PIXEL_SIZE, PIXEL_SIZE)
          else if player.direction.shoot.right
            context.fillRect(player_x + PIXEL_SIZE * 3, player_y - PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE * 3)
            context.fillRect(player_x + PIXEL_SIZE * 4, player_y, PIXEL_SIZE, PIXEL_SIZE)
      
      else
        distance = 2 * PIXEL_SIZE
        player_x = distance if player.x < @clippingX 
        player_x = cWidth - distance if player.x > (@clippingX + @clippingWidth)
        player_y = distance if player.y < @clippingY
        player_y = cHeight - distance if player.y > (@clippingY + @clippingHeight)

        context.fillRect(player_x - PIXEL_SIZE, player_y  - PIXEL_SIZE, PIXEL_SIZE * 1 , PIXEL_SIZE * 1)
        
    
    drawBullets = ->
      context.fillStyle = COLOR_BULLET
      for bullet in gameBullets
        [bullet_x, bullet_y] = transformCoords(bullet.x, bullet.y)
        context.fillRect(bullet_x, bullet_y, PIXEL_SIZE, PIXEL_SIZE)

    drawMap = ->
      context.fillStyle = COLOR_OBSTACLE
      realX = 0

      for w in [clippingX..(clippingX + clippingWidth)]
        realY = 0
        for h in [clippingY..(clippingY + clippingHeight)]
          unless w < 0 or h < 0 or w > (gameWorld.length - 1) or h > (gameWorld[0].length - 1)
            if gameWorld[w][h] > 0
              context.fillRect(realX,realY,PIXEL_SIZE, PIXEL_SIZE)
          
          realY += PIXEL_SIZE
        realX += PIXEL_SIZE
    
    resize = ->
      context.canvas.width = window.innerWidth
      context.canvas.height = window.innerHeight - 100
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

    transformCoords = (x,y) ->
      tx = ((x - @controlled.x) * PIXEL_SIZE) + @relativeX
      ty = ((y - @controlled.y) * PIXEL_SIZE) + @relativeY
      return [tx, ty]


    # Init

    resize()
    draw()
            
else
  alert 'Your browser does not support websockets.'

