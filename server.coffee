express     = require 'express'
io          = require 'socket.io'
fs          = require 'fs'
util        = require 'util'

config      = global.config = require('./config/config')
application = global.application = require('./config/application.coffee')

process.on "uncaughtException", (err) ->
  console.log "UNCAUGHT EXCEPTION:"
  console.log err.stack

### Server ###

server = express.createServer()
application.expressConfig(express, server)
  
### Handle Connections ###

io = io.listen server

### Start Server ### 

server.get '/', (req, res) ->
  res.render 'index', { host: config.server.host, port: config.server.port }

server.listen(config.server.port)

util.puts("Started server in #{server.settings.env} mode, listening at #{config.server.host} to port #{config.server.port}.")