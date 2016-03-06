_ = require 'lodash'
app = require '../../server/server'
bluebird = require 'bluebird'
chai = require 'chai'
should = chai.should()
sinon = require 'sinon'
taskAuthorizationChecker = require '../../server/service/task-authorization-checker'
using = require '../common/utils/data-provider'

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

        promise = taskAuthorizationChecker.checkTasksAreMine 'testCreator', data.tasks
        if data.authorized
          promise.then ->
            Task.getMyTasks.should.have.been.calledWithExactly 'testCreator'
            done()
        else
          promise.catch (error) ->
            Task.getMyTasks.should.have.been.calledWithExactly 'testCreator'
            error.should.equal 'NOT_MY_TASKS'
            done()
