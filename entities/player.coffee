Bullet = require('./bullet')

COOLDOWN = 7
BULLET_SPEED = 2

module.exports = class
  constructor: (@id, @client, @x, @y) ->
    @move = {
      left: false
      up: false
      right: false
      down: false
    }

    @shoot = {
      left: true
      up: false
      right: false
      down: false
    }

    @shooting = false
    @disconnected = false

    @cooldown = 0

  doStep: ->
    @cooldown -= 1 if @cooldown > 0

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
      cooldown: @cooldown
    }

  hit: ->
    return null

  getBullet: ->
    bX = @x
    bY = @y
    tX = 0
    tY = 0

    if @shoot.left
      tX = -BULLET_SPEED
    else if @shoot.up
      tY = -BULLET_SPEED
    else if @shoot.right
      tX = BULLET_SPEED
    else if @shoot.down
      tY = BULLET_SPEED

    @cooldown = COOLDOWN

    return new Bullet(@id, bX, bY, tX, tY)

  addMoveDirection: (direction) ->
    @move[direction] = true

  removeMoveDirection: (direction) ->
    @move[direction] = false

  startShooting: ->
    if @.isMoving() is true and @shooting is false
      # Only one direction allowed atm
      @shoot = {
        left: false
        up: false
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