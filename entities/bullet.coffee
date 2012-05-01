Shapes = require('./shapes')

module.exports = class

  constructor: (@playerId, @x, @y, @trajX, @trajY, @damageRadius) ->

  data: ->
    return {
      playerId: @playerId
      x: @x
      y: @y
      trajX: @trajX
      trajY: @trajY
    }

  # returns an array with the coordinates
  # of the damage field at X and Y.
  getFieldOfDamageAt: (x, y) ->
    return [[x, y]] if @damageRadius < 2 
    
    field = []
    hsize = @damageRadius

    # circular damage for explosions
    field = Shapes.filledCircle @damageRadius

    #translate field of damage to x/y
    for coord in field
      coord[0] += x
      coord[1] += y

    return field
