loopback = require 'loopback'

find = ->
  loopbackContext = loopback.getCurrentContext()
  loopbackContext?.get? 'currentUser'

module.exports =
  find: find
