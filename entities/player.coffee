module.exports = class
  constructor: (@client) ->
    console.log "Hello"
    return

  disconnect: ->
    console.log "Goodbye"
    return