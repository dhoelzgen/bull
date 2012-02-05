module.exports = class
  constructor: (@id, @client, @x, @y) ->
    @direction = 'stop'
    @disconnected = false

  data: ->
    return {
      id: @id
      x: @x
      y: @y
    }

  setDirection: (direction) ->
    @direction = direction