boot = require 'loopback-boot'
loopback = require 'loopback'
promisify = require 'loopback-promisify'

app = module.exports = loopback()

app.start = ->
  app.listen ->
    app.emit 'started'
    baseUrl = app.get('url').replace(/\/$/, '')
    console.log 'Web server listening at: %s', baseUrl
    if app.get('loopback-component-explorer')
      explorerPath = app.get('loopback-component-explorer').mountPath
      console.log 'Browse your REST API at %s%s', baseUrl, explorerPath
    return

boot app, __dirname, (err) ->
  if err
    throw err

  promisify app

  if require.main == module
    app.start()
  return
