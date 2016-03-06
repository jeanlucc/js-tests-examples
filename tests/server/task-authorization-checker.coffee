_ = require 'lodash'
app = require '../../server/server'
bluebird = require 'bluebird'
chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
loopback = require 'loopback'
should = chai.should()
sinon = require 'sinon'
taskAuthorizationChecker = require '../../server/service/task-authorization-checker'
using = require '../common/utils/data-provider'

chai.use chaiAsPromised

Task = app.models.Task

describe 'taskAuthorizationChecker', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create()

  afterEach ->
    @sandbox.restore()

  describe 'checkTasksAreMine', ->
    it 'should fail if getMyTasks fails', (done) ->
      @sandbox.stub(Task, 'getMyTasks').returns bluebird.reject 'DB_ERROR'
      taskAuthorizationChecker.checkTasksAreMine().should.be.rejectedWith('DB_ERROR').and.notify done

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
    ], (testCase) ->
      testCase.tasks = _.map testCase.tasks, (id) -> id: id
      testCase.myTasks = _.map testCase.myTasks, (id) -> id: id
      testCase

    using tasksDataProvider, (data) ->
      it 'should be rejected when a task is not one of mine, fulfilled otherwise', (done) ->
        @sandbox.stub(Task, 'getMyTasks').returns bluebird.resolve data.myTasks

        promise = taskAuthorizationChecker.checkTasksAreMine data.tasks
        if data.authorized
          promise.should.be.fulfilled.and.notify done
        else
          promise.should.be.rejectedWith('NOT_MY_TASKS').and.notify done
