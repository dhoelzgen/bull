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
    host: "dhmbpro.local"
    port: 3030