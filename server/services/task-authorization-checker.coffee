_ = require 'lodash'
bluebird = require 'bluebird'
loopback = require 'loopback'

Task = loopback.getModel 'Task'

checkTasksAreMine = (creator, tasks) ->
  Task.getMyTasks creator
  .then (myTasks) ->
    tasksId = _.map tasks, 'id'
    myTasksId = _.map myTasks, 'id'
    unauthorizedTasksId = _.difference tasksId, myTasksId
    if unauthorizedTasksId.length is 0 then bluebird.resolve() else bluebird.reject 'NOT_MY_TASKS'

module.exports =
  checkTasksAreMine: checkTasksAreMine
