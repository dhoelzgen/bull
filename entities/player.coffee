module.exports = class
  constructor: (@id, @client, @x, @y) ->
    @move = {
      left: false
      top: false
      right: false
      down: false
    }

    @shoot = {
      left: false
      top: false
      right: false
      down: false
    }

    @shooting = false
    @disconnected = false

  data: ->
    return {
      id: @id
      direction: {
        move: @move
        shoot: @shoot
      }
      shooting: @shooting
      x: @x
      y: @y
    }

  addMoveDirection: (direction) ->
    @move[direction] = true

  removeMoveDirection: (direction) ->
    @move[direction] = false

  startShooting: ->
    if @.isMoving() is true and @shooting is false
      # Only one direction allowed atm
      @shoot = {
        left: false
        top: false
        right: false
        down: false
      }

      if @move.left
        @shoot.left = true
      else if @move.up
        @shoot.up = true
      else if @move.right
        @shoot.right = true
      else
        @shoot.down = true
    
    @shooting = true

  stopShooting: ->
    @shooting = false

  isMoving: ->
    if @move.left is false and @move.right is false and @move.up is false and @move.down is false
      return false
    else
      return true