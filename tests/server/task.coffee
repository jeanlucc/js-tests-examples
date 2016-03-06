_ = require 'lodash'
app = require '../../server/server'
bluebird = require 'bluebird'
currentUserProvider = require '../../server/service/current-user-provider'
loopback = require 'loopback'
should = require('chai').should()
sinon = require 'sinon'
taskAuthorizationChecker = require '../../server/service/task-authorization-checker'
taskSanitizer = require '../../server/service/task-sanitizer'
using = require '../common/utils/data-provider'

Task = app.models.Task

describe 'Task', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create()

  afterEach ->
    @sandbox.restore()

  describe 'getMyTasks', ->
    beforeEach ->
      @currentUserProviderFindStub = @sandbox.stub(currentUserProvider, 'find').returns id: 42
      @TaskFindStub = @sandbox.stub(Task, 'find').returns bluebird.resolve ['task1', 'task2']

    noCurrentUserDataProvider = [
      null
      name: 'Bobby'
    ]
    using noCurrentUserDataProvider, (user) ->
      it 'should fail if there is no current user', (done) ->
        @currentUserProviderFindStub.returns user
        Task.getMyTasks()
        .catch (error) ->
          error.should.equal 'NO_CURRENT_USER'
          done()

    it 'should fail if find of tasks fails', (done) ->
      @TaskFindStub.returns bluebird.reject 'DB_ERROR'
      Task.getMyTasks()
      .catch (error) ->
        error.should.equal 'DB_ERROR'
        done()

    it 'should return task of current user', (done) ->
      Task.getMyTasks()
      .then (tasks) ->
        Task.find.should.have.been.calledWithExactly where: ownerId: 42
        tasks.should.deep.equal ['task1', 'task2']
        done()

  describe 'safeSave', ->
    beforeEach ->
      @taskSanitizerStub = @sandbox.stub(taskSanitizer, 'sanitize').returns id: 51, date: '15-11-1240'
      @TaskUpsertStub = @sandbox.stub(Task, 'upsert').returns bluebird.resolve id: 24

    it 'should fail if upsert fails', (done) ->
      @TaskUpsertStub.returns bluebird.reject 'UPSERT_ERROR'
      Task.safeSave()
      .catch (error) ->
        error.should.equal 'UPSERT_ERROR'
        done()

    it 'should upsert sanitized task', (done) ->
      Task.safeSave id: 42
      .then (savedTask) ->
        taskSanitizer.sanitize.should.have.been.calledWithExactly id: 42
        Task.upsert.should.have.been.calledWithExactly id: 51, date: '15-11-1240'
        savedTask.should.deep.equal id: 24
        done()

  describe 'batchDelete', ->
    beforeEach ->
      @checkTasksAreMineStub = @sandbox.stub(taskAuthorizationChecker, 'checkTasksAreMine').returns bluebird.resolve()
      @TaskDestroyAllStub = @sandbox.stub(Task, 'destroyAll').returns bluebird.resolve()

    it 'should fail if user has no authorization', (done) ->
      @checkTasksAreMineStub.returns bluebird.reject 'AUTHORIZATION_ERROR'
      Task.batchDelete()
      .catch (error) ->
        error.should.equal 'AUTHORIZATION_ERROR'
        done()

    it 'should fail if destroyAll fails', (done) ->
      @TaskDestroyAllStub.returns bluebird.reject 'DB_ERROR'
      Task.batchDelete()
      .catch (error) ->
        error.should.equal 'DB_ERROR'
        done()

    it 'should destroyAll', (done) ->
      Task.batchDelete [{id: 1}, {id: 2}, {id: 3}]
      .then (result) ->
        should.not.exist result
        taskAuthorizationChecker.checkTasksAreMine.should.have.been.calledWithExactly [{id: 1}, {id: 2}, {id: 3}]
        Task.destroyAll.should.have.been.calledWithExactly id: inq: [1, 2, 3]
        done()
