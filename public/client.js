(function() {
  var PIXEL_SIZE;
  if (window['WebSocket']) {
    PIXEL_SIZE = 5;
    $(document).ready(function() {
      var cHeight, cWidth, canvas, connect, context, draw, drawMap, drawPlayer, gameId, gamePlayers, gameWorld, getPlayer, redraw, resize, sendDirection, server;
      server = null;
      canvas = $('#game');
      context = canvas.get(0).getContext('2d');
      gameWorld = null;
      gamePlayers = [];
      gameId = null;
      cWidth = 0;
      cHeight = 0;
      sendDirection = function(direction) {
        return server.emit('action.direction', direction);
      };
      connect = function() {
        server = io.connect(host, {
          'port': parseInt(port)
        });
        return server.on('connect', function() {
          server.on('game.step', function(data) {
            return gamePlayers = data.players;
          });
          return server.on('game.init', function(data) {
            gameWorld = data.world;
            window.world = data.world;
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
            return sendDirection('left');
          case 38:
            return sendDirection('up');
          case 39:
            return sendDirection('right');
          case 40:
            return sendDirection('down');
        }
      });
      redraw = function() {
        context.fillStyle = 'rgb(0,0,0)';
        context.fillRect(0, 0, context.canvas.width, context.canvas.height);
        this.player = getPlayer();
        if (!this.player) {
          return;
        }
        this.realPlayerX = parseInt(cWidth / 2);
        this.realPlayerY = parseInt(cHeight / 2);
        this.clippingX = player.x - parseInt(cWidth / (2 * PIXEL_SIZE));
        this.clippingY = player.y - parseInt(cHeight / (2 * PIXEL_SIZE));
        this.clippingWidth = parseInt(cWidth / PIXEL_SIZE);
        this.clippingHeight = parseInt(cHeight / PIXEL_SIZE);
        drawMap();
        return drawPlayer();
      };
      drawPlayer = function() {
        context.fillStyle = 'rgb(255,0,0)';
        return context.fillRect(this.realPlayerX, this.realPlayerY, PIXEL_SIZE, PIXEL_SIZE);
      };
      drawMap = function() {
        var h, realX, realY, w, _ref, _ref2, _results;
        context.fillStyle = 'rgb(255,255,255)';
        realX = 0;
        _results = [];
        for (w = clippingX, _ref = clippingX + clippingWidth; clippingX <= _ref ? w <= _ref : w >= _ref; clippingX <= _ref ? w++ : w--) {
          realY = 0;
          for (h = clippingY, _ref2 = clippingY + clippingHeight; clippingY <= _ref2 ? h <= _ref2 : h >= _ref2; clippingY <= _ref2 ? h++ : h--) {
            if (!(w < 0 || h < 0 || w > (gameWorld.length - 1) || h > (gameWorld[0].length - 1))) {
              if (gameWorld[w][h] === 1) {
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
        context.canvas.height = window.innerHeight - 140;
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
      resize();
      return draw();
    });
  } else {
    alert('Your browser does not support websockets.');
  }
}).call(this);
