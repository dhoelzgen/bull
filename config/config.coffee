currentEnv = process.env.NODE_ENV or 'development'

exports.appName = "Bull"

exports.env =
  production: false
  staging: false
  test: false
  development: false

exports.env[currentEnv] = true

if currentEnv == "development"
  exports.server =
    host: "127.0.0.1"
    port: 3000

if currentEnv == "production"
  exports.server =
    host: "bull.9elements.com"
    port: 5123
