bluebird = require 'bluebird'
currentUserProvider = require '../../server/service/current-user-provider'
taskAuthorizationChecker = require '../../server/service/task-authorization-checker'
taskSanitizer = require '../../server/service/task-sanitizer'

module.exports = (Task) ->

  Task.getMyTasks = ->
    currentUser = currentUserProvider.find()
    return bluebird.reject 'NO_CURRENT_USER' unless currentUser?.id?
    Task.find where: ownerId: currentUser.id

  Task.saveWithDate = (task) ->
    taskToUpdate = taskSanitizer.sanitize task
    Task.upsert taskToUpdate

  Task.batchDelete = (tasks) ->
    taskAuthorizationChecker.checkTasksAreMine tasks
    .then
      Task.destroyAll id: inq: _.map tasks, 'id'
