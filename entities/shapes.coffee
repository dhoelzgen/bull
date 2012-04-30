module.exports =

  # creates a filled circle, represented
  # by an array of coordinates.
  # the center of the circle is at 
  # x:0 and y:0
  filledCircle: (radius) ->
    coordinates = []
    xoff        = 0
    yoff        = radius
    balance     = -radius
    xp          = radius
    yp          = radius
    
    while xoff <= yoff
      p0 = xp - xoff
      p1 = xp - yoff
      w0 = xoff + xoff
      w1 = yoff + yoff
      
      line = (xp, yp, w, offset) ->
        for i in [0..w]
          coordinates.push [xp + i - offset, yp - offset]
      
      line p0, yp + yoff, w0, radius
      line p0, yp - yoff, w0, radius
      line p1, yp + xoff, w1, radius
      line p1, yp - xoff, w1, radius
     
      balance += xoff + xoff
      xoff    += 1
      if balance >= 0
        yoff    -= 1
        balance -= yoff + yoff
    
    return coordinates

