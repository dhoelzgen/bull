Bullet = require('./bullet')

weaponData =
  laser:
    cooldown: 7
    speed: 2
    radius: 1
  rocket:
    cooldown: 20
    speed: 1
    radius: 3

HITPOINTS = 5

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
    @dead = false
    @hitpoints = HITPOINTS
    @weapon = 'laser'

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
      dead: @dead
      cooldown: @cooldown
    }

  hit: ->
    @hitpoints -= 1
    @.die() if @hitpoints == 0

  die: ->
    @dead = true
    @cooldown = 50

  resurrect: (x,y) ->
    @x = x
    @y = y
    @hitpoints = HITPOINTS
    @dead = false

  getBullet: ->
    bX = @x
    bY = @y
    tX = 0
    tY = 0

    if @shoot.left
      tX = -weaponData[@weapon].speed
    else if @shoot.up
      tY = -weaponData[@weapon].speed
    else if @shoot.right
      tX = weaponData[@weapon].speed
    else if @shoot.down
      tY = weaponData[@weapon].speed

    @cooldown = weaponData[@weapon].cooldown

    return new Bullet(@id, bX, bY, tX, tY, weaponData[@weapon].radius)

  addMoveDirection: (direction) ->
    @move[direction] = true

  removeMoveDirection: (direction) ->
    @move[direction] = false

  startShooting: (weapon)  ->
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
    
    @weapon = weapon
    @shooting = true

  stopShooting: ->
    @shooting = false

  isMoving: ->
    if @move.left is false and @move.right is false and @move.up is false and @move.down is false
      return false
    else
      return true
