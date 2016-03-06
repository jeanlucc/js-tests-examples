_ = require 'lodash'
bluebird = require 'bluebird'
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

  Task.getStaticCallback = (done) ->
    done null, ['this', 'illustrate', 'the', 'basic', 'test', 'of', 'a', 'function', 'which', 'uses', 'a', 'callback']

  Task.getMyTasksCallback = (creator, done) ->
    Task.find
      where: creator: creator
      (error, tasks) ->
        return done error if error
        done null, tasks

  Task.getMyTasks = (creator) ->
    Task.find where: creator: creator

  Task.safeSave = (task) ->
    taskToUpdate = taskSanitizer.sanitize task
    Task.upsert taskToUpdate

  Task.batchDelete = (creator, tasks) ->
    taskAuthorizationChecker.checkTasksAreMine creator, tasks
    .then ->
      Task.destroyAll id: inq: _.map tasks, 'id'

  Task.remoteMethod 'getStaticCallback',
    returns: {type: 'array', root: true}
    http:
      verb: 'GET'
      path: '/static'
    description: 'return a static array of strings to have the simplest example of code wih callback'
