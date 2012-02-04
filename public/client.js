(function() {
  if (window["WebSocket"]) {
    $(document).ready(function() {
      var canvas, connect, context, draw, redraw, resize, sendDirection, server;
      server = null;
      canvas = $("#game");
      context = canvas.get(0).getContext("2d");
      sendDirection = function(direction) {
        if (server) {
          return server.send(JSON.stringify({
            'action:direction': direction
          }));
        }
      };
      connect = function() {
        console.log("CONNECTING TO " + host + " ON " + port);
        return server = io.connect(host, {
          'port': parseInt(port)
        });
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
      resize = function() {
        context.canvas.width = window.innerWidth;
        context.canvas.height = window.innerHeight - 140;
        return redraw();
      };
      $(window).resize(resize);
      draw = function() {
        redraw();
        return window.setTimeout(function() {
          return draw();
        }, 33);
      };
      redraw = function() {
        context.fillStyle = 'rgb(0,0,0)';
        return context.fillRect(0, 0, context.canvas.width, context.canvas.height);
      };
      resize();
      return draw();
    });
  } else {
    alert("Your browser does not support websockets.");
  }
}).call(this);
