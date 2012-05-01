Player = require('./entities/player')
World  = require('./entities/world')

Array::remove = (e) -> @[t..t] = [] if (t = @.indexOf(e)) > -1

module.exports = class
  constructor: (@io) ->
    @players = []
    @nextId = 1

  go: ->
    @world = new World 750, 750
    @bullets = []

    @io.sockets.on "connection", (client) =>
      @.addClient client

    @.nextCycle()

  addClient: (client) ->
    [x, y] = @world.nextSpawnPoint()
    id = @nextId
    @nextId += 1

    player = new Player id, client, x, y

    @players.push player

    client.on "action.move", (direction) ->
      player.addMoveDirection direction

    client.on "action.stop", (direction) ->
      player.removeMoveDirection direction

    client.on "action.shoot", (weapon) ->
      return unless ['laser', 'rocket'].indexOf(weapon) isnt -1
      player.startShooting(weapon)

    client.on "action.stopShooting", ->
      player.stopShooting()

    client.on "disconnect", =>
      @players.remove(player)

    # Send initial data

    client.emit "game.init", {
      world: @world.data()
      id: player.id
      count: @players.length
    }

  movePlayer: (player) ->

    newX = player.x
    newY = player.y

    if player.move.left  then newX -= 1
    if player.move.right  then newX += 1
    if player.move.up then newY -= 1
    if player.move.down  then newY += 1

    # X

    free = true
    
    for i in [-1..1]
      for j in [-1..1]
        free = false if @world.get( newX + i, player.y + j) > 0

    for other in @players
      unless other is player
        free = false if Math.abs(other.x - newX) < 3 and Math.abs(other.y - player.y) < 3

    if free
      player.x = newX

    # Y

    free = true
    
    for i in [-1..1]
      for j in [-1..1]
        free = false if @world.get( player.x + i, newY + j) > 0

    for other in @players
      unless other is player
        free = false if Math.abs(other.x - player.x) < 3 and Math.abs(other.y - newY) < 3

    if free
      player.y = newY

  resurrectPlayer: (player) ->
    if player.cooldown == 0
      [x, y] = @world.nextSpawnPoint()
      player.resurrect x, y

  nextCycle: ->
   
    sounds =
      shoot: false
      hit: false
      envhit: false

    # Move & Shoot

    for player in @players
      player.doStep()

      if player.dead
        @.resurrectPlayer player
      else
        @.movePlayer player


      if player.shooting and player.cooldown == 0
        sounds.shoot = true
        @bullets.push player.getBullet()
    
    # Die

    checkCollision = (bullet, playerId, x, y) =>
      if @world.get(x,y) > 0
        sounds.envhit = true
        @world.hit(bullet, x, y)
        return true
      else
        for player in @players
          if playerId isnt player.id
            for i in [-1..1]
              for j in [-1..1]
                if player.x == (x + i) and player.y == (y + j)
                  player.hit()
                  sounds.hit = true
                  return true

      return false

    remainingBullets = []

    for bullet in @bullets
      collision = false
      if bullet.trajY == 0
        for i in [bullet.x..(bullet.x + bullet.trajX)]
          collision = true if checkCollision(bullet, bullet.playerId, i, bullet.y)
      else
        for i in [bullet.y..(bullet.y + bullet.trajY)]
          collision = true if checkCollision(bullet, bullet.playerId, bullet.x, i)

      remainingBullets.push( bullet ) unless collision
    
    bulletData = []

    for bullet in remainingBullets
      bullet.x += bullet.trajX
      bullet.y += bullet.trajY
      bulletData.push bullet.data()

    @bullets = remainingBullets

    # Tell

    playerData = []

    for player in @players
      playerData.push player.data()

    @io.sockets.emit "game.step", {
      players: playerData
      bullets: bulletData
      changes: @world.changelist
      sounds: sounds
    }

    @world.resetChangeList()

    setTimeout =>
      @.nextCycle()
    , 33

