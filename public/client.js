(function() {
  var COLOR_BULLET, COLOR_CLEAN, COLOR_DEAD, COLOR_ENEMY, COLOR_OBSTACLE, COLOR_SELF, PIXEL_SIZE;
  if (window['WebSocket']) {
    PIXEL_SIZE = 5;
    COLOR_SELF = '#3d700a';
    COLOR_ENEMY = '#498d05';
    COLOR_DEAD = '#253008';
    COLOR_BULLET = '#3d700a';
    COLOR_OBSTACLE = '#253008';
    COLOR_CLEAN = '#304818';
    $(document).ready(function() {
      var cHeight, cWidth, canvas, connect, context, draw, drawBullets, drawMap, drawPlayer, gameBullets, gameId, gamePlayers, gameWorld, getPlayer, redraw, resize, sendMove, sendShoot, sendStop, sendStopShooting, server, transformCoords;
      server = null;
      canvas = $('#game');
      context = canvas.get(0).getContext('2d');
      gameWorld = null;
      gameBullets = null;
      gamePlayers = [];
      gameId = null;
      cWidth = 0;
      cHeight = 0;
      sendMove = function(direction) {
        return server.emit('action.move', direction);
      };
      sendStop = function(direction) {
        return server.emit('action.stop', direction);
      };
      sendShoot = function() {
        return server.emit('action.shoot', null);
      };
      sendStopShooting = function() {
        return server.emit('action.stopShooting', null);
      };
      connect = function() {
        server = io.connect(host, {
          'port': parseInt(port)
        });
        return server.on('connect', function() {
          server.on('game.step', function(data) {
            var change, _i, _len, _ref, _results;
            gamePlayers = data.players;
            gameBullets = data.bullets;
            _ref = data.changes;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              change = _ref[_i];
              _results.push(gameWorld[change.x][change.y] = 0);
            }
            return _results;
          });
          return server.on('game.init', function(data) {
            gameWorld = data.world;
            return gameId = data.id;
          });
        });
      };
      connect();
      $(document).keydown(function(event) {
        var key;
        if (!server) {
          return;
        }
        key = event.keyCode ? event.keyCode : event.which;
        switch (key) {
          case 37:
            return sendMove('left');
          case 38:
            return sendMove('up');
          case 39:
            return sendMove('right');
          case 40:
            return sendMove('down');
          case 32:
            return sendShoot();
        }
      });
      $(document).keyup(function(event) {
        var key;
        if (!server) {
          return;
        }
        key = event.keyCode ? event.keyCode : event.which;
        switch (key) {
          case 37:
            return sendStop('left');
          case 38:
            return sendStop('up');
          case 39:
            return sendStop('right');
          case 40:
            return sendStop('down');
          case 32:
            return sendStopShooting();
        }
      });
      redraw = function() {
        var player, _i, _len;
        context.fillStyle = COLOR_CLEAN;
        context.fillRect(0, 0, context.canvas.width, context.canvas.height);
        this.controlled = getPlayer();
        if (!this.controlled) {
          return;
        }
        this.relativeX = parseInt(cWidth / 2) - parseInt(cWidth / 2 % PIXEL_SIZE);
        this.relativeY = parseInt(cHeight / 2) - parseInt(cHeight / 2 % PIXEL_SIZE);
        this.clippingX = this.controlled.x - parseInt(cWidth / (2 * PIXEL_SIZE));
        this.clippingY = this.controlled.y - parseInt(cHeight / (2 * PIXEL_SIZE));
        this.clippingWidth = parseInt(cWidth / PIXEL_SIZE);
        this.clippingHeight = parseInt(cHeight / PIXEL_SIZE);
        drawMap();
        for (_i = 0, _len = gamePlayers.length; _i < _len; _i++) {
          player = gamePlayers[_i];
          drawPlayer(player);
        }
        return drawBullets();
      };
      drawPlayer = function(player) {
        var distance, player_x, player_y, _ref;
        if (player.dead) {
          context.fillStyle = COLOR_DEAD;
        } else {
          if (player === this.controlled) {
            context.fillStyle = COLOR_SELF;
          } else {
            context.fillStyle = COLOR_ENEMY;
          }
        }
        _ref = transformCoords(player.x, player.y), player_x = _ref[0], player_y = _ref[1];
        if (player.x > this.clippingX && player.x < (this.clippingX + this.clippingWidth) && player.y > this.clippingY && player.y < (this.clippingY + this.clippingHeight)) {
          context.fillRect(player_x - PIXEL_SIZE, player_y - PIXEL_SIZE, PIXEL_SIZE * 3, PIXEL_SIZE * 3);
          if (player.shooting) {
            if (player.direction.shoot.up) {
              context.fillRect(player_x - PIXEL_SIZE, player_y - PIXEL_SIZE * 3, PIXEL_SIZE * 3, PIXEL_SIZE);
              return context.fillRect(player_x, player_y - PIXEL_SIZE * 4, PIXEL_SIZE, PIXEL_SIZE);
            } else if (player.direction.shoot.down) {
              context.fillRect(player_x - PIXEL_SIZE, player_y + PIXEL_SIZE * 3, PIXEL_SIZE * 3, PIXEL_SIZE);
              return context.fillRect(player_x, player_y + PIXEL_SIZE * 4, PIXEL_SIZE, PIXEL_SIZE);
            } else if (player.direction.shoot.left) {
              context.fillRect(player_x - PIXEL_SIZE * 3, player_y - PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE * 3);
              return context.fillRect(player_x - PIXEL_SIZE * 4, player_y, PIXEL_SIZE, PIXEL_SIZE);
            } else if (player.direction.shoot.right) {
              context.fillRect(player_x + PIXEL_SIZE * 3, player_y - PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE * 3);
              return context.fillRect(player_x + PIXEL_SIZE * 4, player_y, PIXEL_SIZE, PIXEL_SIZE);
            }
          }
        } else {
          distance = 2 * PIXEL_SIZE;
          if (player.x < this.clippingX) {
            player_x = distance;
          }
          if (player.x > (this.clippingX + this.clippingWidth)) {
            player_x = cWidth - distance;
          }
          if (player.y < this.clippingY) {
            player_y = distance;
          }
          if (player.y > (this.clippingY + this.clippingHeight)) {
            player_y = cHeight - distance;
          }
          return context.fillRect(player_x - PIXEL_SIZE, player_y - PIXEL_SIZE, PIXEL_SIZE * 1, PIXEL_SIZE * 1);
        }
      };
      drawBullets = function() {
        var bullet, bullet_x, bullet_y, _i, _len, _ref, _results;
        context.fillStyle = COLOR_BULLET;
        _results = [];
        for (_i = 0, _len = gameBullets.length; _i < _len; _i++) {
          bullet = gameBullets[_i];
          _ref = transformCoords(bullet.x, bullet.y), bullet_x = _ref[0], bullet_y = _ref[1];
          _results.push(context.fillRect(bullet_x, bullet_y, PIXEL_SIZE, PIXEL_SIZE));
        }
        return _results;
      };
      drawMap = function() {
        var h, realX, realY, w, _ref, _ref2, _results;
        context.fillStyle = COLOR_OBSTACLE;
        realX = 0;
        _results = [];
        for (w = clippingX, _ref = clippingX + clippingWidth; clippingX <= _ref ? w <= _ref : w >= _ref; clippingX <= _ref ? w++ : w--) {
          realY = 0;
          for (h = clippingY, _ref2 = clippingY + clippingHeight; clippingY <= _ref2 ? h <= _ref2 : h >= _ref2; clippingY <= _ref2 ? h++ : h--) {
            if (!(w < 0 || h < 0 || w > (gameWorld.length - 1) || h > (gameWorld[0].length - 1))) {
              if (gameWorld[w][h] > 0) {
                context.fillRect(realX, realY, PIXEL_SIZE, PIXEL_SIZE);
              }
            }
            realY += PIXEL_SIZE;
          }
          _results.push(realX += PIXEL_SIZE);
        }
        return _results;
      };
      resize = function() {
        context.canvas.width = window.innerWidth;
        context.canvas.height = window.innerHeight - 100;
        cWidth = context.canvas.width;
        cHeight = context.canvas.height;
        return redraw();
      };
      $(window).resize(resize);
      draw = function() {
        redraw();
        return window.setTimeout(function() {
          return draw();
        }, 33);
      };
      getPlayer = function() {
        var player, _i, _len;
        for (_i = 0, _len = gamePlayers.length; _i < _len; _i++) {
          player = gamePlayers[_i];
          if (player.id === gameId) {
            return player;
          }
        }
        return null;
      };
      transformCoords = function(x, y) {
        var tx, ty;
        tx = ((x - this.controlled.x) * PIXEL_SIZE) + this.relativeX;
        ty = ((y - this.controlled.y) * PIXEL_SIZE) + this.relativeY;
        return [tx, ty];
      };
      resize();
      return draw();
    });
  } else {
    alert('Your browser does not support websockets.');
  }
}).call(this);
