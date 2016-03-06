_ = require 'lodash'
bluebird = require 'bluebird'
currentUserProvider = require '../../server/service/current-user-provider'
taskAuthorizationChecker = require '../../server/service/task-authorization-checker'
taskSanitizer = require '../../server/service/task-sanitizer'

module.exports = (Task) ->

  Task.disableRemoteMethod('create', true);
  Task.disableRemoteMethod('updateAttributes', false);
  Task.disableRemoteMethod('updateAll', true);

  Task.disableRemoteMethod('findById', true);
  Task.disableRemoteMethod('findOne', true);
  Task.disableRemoteMethod('exists', true);
  Task.disableRemoteMethod('count', true);

  Task.disableRemoteMethod('deleteById', true);

  Task.disableRemoteMethod('__get__owner', false);
  Task.disableRemoteMethod('createChangeStream', true);

  Task.getMyTasks = (creator) ->
    Task.find where: creator: creator

  Task.safeSave = (task) ->
    taskToUpdate = taskSanitizer.sanitize task
    Task.upsert taskToUpdate

  Task.batchDelete = (tasks) ->
    taskAuthorizationChecker.checkTasksAreMine tasks
    .then ->
      Task.destroyAll id: inq: _.map tasks, 'id'
