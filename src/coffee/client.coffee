if window["WebSocket"]
  
  $(document).ready ->
    server = null
    canvas = $("#game")
    context = canvas.get(0).getContext("2d")
    
    sendDirection = (direction) ->
      server.send(JSON.stringify({'direction': direction})) if server

    connect = ->
      server = new io.Socket(host, { 'port': parseInt(port) })
      server.connect()
      
    connect()
    
    $(document).keydown (event) ->
      key = if event.keyCode then event.keyCode else event.which
      switch key
        when 37 then sendDirection "left"
        when 38 then sendDirection "up"
        when 39 then sendDirection "right"
        when 40 then sendDirection "down"

    # TESTING ONLY

    state = false

    resize = ->
      context.canvas.width = window.innerWidth
      context.canvas.height = window.innerHeight - 120
      redraw()

    $(window).resize resize

    redraw = ->
      if state
        context.fillStyle = 'rgb(0,0,0)'
      else
        context.fillStyle = 'rgb(255,0,0)'

      context.fillRect(0,0,30,30)
      context.fillRect(canvas.width() - 30, 0, 30, 30)
      context.fillRect(0, canvas.height() - 30, 30, 30)
      context.fillRect(canvas.width() - 30, canvas.height() - 30, 30, 30)

    draw = ->
      redraw()

      window.setTimeout ->
        draw()
      , 33

    flash =  ->
      state = not state

      window.setTimeout ->
        flash(not state)
      , 500

    resize()
    draw()

    flash()
            
else
  alert "Your browser does not support websockets."

