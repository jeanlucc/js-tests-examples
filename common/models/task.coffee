bluebird = require 'bluebird'
currentUserProvider = require '../../server/service/current-user-provider'

module.exports = (Task) ->

  Task.getMyTasks = ->
    currentUser = currentUserProvider.find()
    return bluebird.reject 'NO_CURRENT_USER' unless currentUser?.id?
    Task.find where: ownerId: currentUser.id

  Task.batchDelete = (tasks) ->
