module.exports = 
  expressConfig: (express, server) ->
    server.configure ->
      server.set 'views', __dirname + '/../views'
      server.set 'view engine', 'jade'
      server.use express.bodyParser()
      server.use express.cookieParser()
      server.use express.methodOverride()

      server.use require("stylus").middleware
        src: __dirname + '/../src/stylus/'
        dest: __dirname + '/../public'
        compress: true

      server.use express.compiler
        src: "#{__dirname}/../src/coffee/"
        dest: "#{__dirname}/../public"
        enable: ['coffeescript']

      server.use express.static(__dirname + '/../public')
      server.use express.logger()
      server.use express.errorHandler()
      server.use server.router

    server.configure 'development', ->
      server.use express.errorHandler({
        dumpExceptions: true,
        showStack: true
      })
      
    server.configure 'production', ->
      server.use express.errorHandler()