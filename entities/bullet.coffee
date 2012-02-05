module.exports = class

  constructor: (@playerId, @x, @y, @trajX, @trajY) ->

  data: ->
    return {
      playerId: @playerId
      x: @x
      y: @y
      trajX: @trajX
      trajY: @trajY
    }
  