Player = require('./entities/player')
World  = require('./entities/world')

Array::remove = (e) -> @[t..t] = [] if (t = @.indexOf(e)) > -1

module.exports = class
  constructor: (@io) ->
    @players = []
    @nextId = 1

  go: ->
    @world = new World 1500, 500

    @io.sockets.on "connection", (client) =>
      @.addClient client

    @.nextCycle()

  addClient: (client) ->
    pos = @world.nextSpawnPoint()
    id = @nextId
    @nextId += 1

    player = new Player id, client, pos.x, pos.y

    @players.push player

    client.on "action.direction", (direction) ->
      player.setDirection direction

    client.on "disconnect", =>
      @players.remove(player)

    # Send initial data

    client.emit "game.init", {
      world: @world.data()
      id: player.id
      count: @players.length  
    }

  nextCycle: ->
    
    # TODO: Calculate new state

    

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

