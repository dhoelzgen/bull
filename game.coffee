Player = require('./entities/player')
World  = require('./entities/world')

Array::remove = (e) -> @[t..t] = [] if (t = @.indexOf(e)) > -1

module.exports = class
  constructor: (@io) ->
    @players = []
    @nextId = 1

  go: ->
    @world = new World 1500, 600

    @io.sockets.on "connection", (client) =>
      @.addClient client

    @.nextCycle()

  addClient: (client) ->
    pos = @world.nextSpawnPoint()
    id = @nextId
    @nextId += 1

    player = new Player id, client, pos.x, pos.y

    @players.push player

    client.on "action.move", (direction) ->
      player.addMoveDirection direction

    client.on "action.stop", (direction) ->
      player.removeMoveDirection direction

    client.on "action.shoot", ->
      player.startShooting()

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

    if player.move.up then newY -= 1
    if player.move.left  then newX -= 1
    if player.move.right  then newX += 1
    if player.move.down  then newY += 1

    free = true
    
    for i in [-1..1]
      for j in [-1..1]
        free = false if @world.get( newX + i, newY + j) == 1

    for other in @players
      unless other is player
        free = false if Math.abs(other.x - newX) < 3 and Math.abs(other.y - newY) < 3

    if free
      player.x = newX
      player.y = newY

  nextCycle: ->
    
    # TODO: Calculate new state

    @.movePlayer player for player in @players
    

    # Emit current world state to clients

    playerData = []

    for player in @players
      playerData.push player.data()

    @io.sockets.emit "game.step", {
      players: playerData
    }

    setTimeout =>
      @.nextCycle()
    , 33

