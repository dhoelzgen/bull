(function() {
  if (window["WebSocket"]) {
    $(document).ready(function() {
      var canvas, connect, context, draw, flash, redraw, resize, sendDirection, server, state;
      server = null;
      canvas = $("#game");
      context = canvas.get(0).getContext("2d");
      sendDirection = function(direction) {
        if (server) {
          return server.send(JSON.stringify({
            'direction': direction
          }));
        }
      };
      connect = function() {
        server = new io.Socket(host, {
          'port': parseInt(port)
        });
        return server.connect();
      };
      connect();
      $(document).keydown(function(event) {
        var key;
        key = event.keyCode ? event.keyCode : event.which;
        switch (key) {
          case 37:
            return sendDirection("left");
          case 38:
            return sendDirection("up");
          case 39:
            return sendDirection("right");
          case 40:
            return sendDirection("down");
        }
      });
      state = false;
      resize = function() {
        context.canvas.width = window.innerWidth;
        context.canvas.height = window.innerHeight - 120;
        return redraw();
      };
      $(window).resize(resize);
      redraw = function() {
        if (state) {
          context.fillStyle = 'rgb(0,0,0)';
        } else {
          context.fillStyle = 'rgb(255,0,0)';
        }
        context.fillRect(0, 0, 30, 30);
        context.fillRect(canvas.width() - 30, 0, 30, 30);
        context.fillRect(0, canvas.height() - 30, 30, 30);
        return context.fillRect(canvas.width() - 30, canvas.height() - 30, 30, 30);
      };
      draw = function() {
        redraw();
        return window.setTimeout(function() {
          return draw();
        }, 33);
      };
      flash = function() {
        state = !state;
        return window.setTimeout(function() {
          return flash(!state);
        }, 500);
      };
      resize();
      draw();
      return flash();
    });
  } else {
    alert("Your browser does not support websockets.");
  }
}).call(this);
