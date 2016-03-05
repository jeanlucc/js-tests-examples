bluebird = require 'bluebird'
loopback = require 'loopback'
should = require('chai').should
sinon = require 'sinon'
taskAuthorizationChecker = require '../../server/service/task-authorization-checker'

Task = loopback.getModel 'Task'

describe 'taskAuthorizationChecker', ->
  describe 'checkTasksAreMine', ->
    it 'should fail if getMyTasks fails', (done) ->
      sinon.stub(Task, getMyTasks).returns bluebird.reject 'DB_ERROR'
      taskAuthorizationChecker.checkTasksAreMine().should.be.rejectedWith('DB_ERROR').and.notify done

    getTasksData = (data) ->
      data.tasks = _.map data.task, (id) -> id: id
      data.myTasks = _.map data.myTasks, (id) -> id: id
      data

    tasksDataProvider = _.map [
      tasks: [1]
      myTasks: []
      authorized: false
    ,
      tasks: [1]
      myTasks: null
      authorized: false
    ,
      tasks: [1]
      authorized: false
    ,
      tasks: [1, 2, 4]
      myTasks: [1, 2, 3]
      authorized: false
    ,
      tasks: [1, 2, 3, 4]
      myTasks: [1, 2, 3]
      authorized: false
    ,
      tasks: []
      myTasks: []
      authorized: true
    ,
      tasks: [2]
      myTasks: [1, 2, 3]
      authorized: true
    ,
      tasks: [1, 2]
      myTasks: [1, 2, 3]
      authorized: true
    ,
      tasks: [1, 2, 3]
      myTasks: [1, 2, 3]
      authorized: true
    ], getTasksData
    using tasksDataProvider, (data) ->
      it 'should be rejected when a task is not one of mine, fulfilled otherwise', (done) ->
        sinon.stub(Task, 'getMyTasks').returns bluebird.resolve data.myTasks

        promise = taskAuthorizationChecker.checkTasksAreMine data.tasks
        if data.authorized
          promise.should.be.fulfilled.and.notify done
        else
          promise.should.be.rejectedWith('NOT_MY_TASKS').and.notify done
