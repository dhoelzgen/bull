Player = require('./entities/player')
World  = require('./entities/world')

module.exports = class
  constructor: (@socket) ->
    @players = []

  go: ->
    console.log "STARTING SERVER"

    @socket.on "connection", (client) =>
      console.log "HEY, THERE IS A NEW PLAYER"
      @.addClient client

  addClient: (client) ->
    player = new Player client

    client.on "action:direction", (direction) ->
      console.log "DIR CHANGE #{player}, #{direction}"

    client.on "disconnect", ->
      player.disconnect()

