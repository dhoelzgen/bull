if window["WebSocket"]
  
  $(document).ready ->
    server = null

    canvas = $("#game")
    context = canvas.get(0).getContext("2d")
    
    sendDirection = (direction) ->
      server.send(JSON.stringify({'action:direction': direction})) if server

    connect = ->
      server = io.connect(host, { 'port': parseInt(port) })
      
    connect()
    
    $(document).keydown (event) ->
      key = if event.keyCode then event.keyCode else event.which
      switch key
        when 37 then sendDirection "left"
        when 38 then sendDirection "up"
        when 39 then sendDirection "right"
        when 40 then sendDirection "down"

    # Drawing

    resize = ->
      context.canvas.width = window.innerWidth
      context.canvas.height = window.innerHeight - 140
      redraw()

    $(window).resize resize

    draw = ->
      redraw()

      window.setTimeout ->
        draw()
      , 33

    redraw = ->
      context.fillStyle = 'rgb(0,0,0)'
      context.fillRect(0,0,context.canvas.width,context.canvas.height)

    resize()
    draw()
            
else
  alert "Your browser does not support websockets."

