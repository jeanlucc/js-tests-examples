bluebird = require 'bluebird'
loopback = require 'loopback'
should = require('chai').should()
sinon = require 'sinon'
taskAuthorizationChecker = require '../../server/service/task-authorization-checker'
taskFilter = require '../../server/service/task-filter'
taskSanitizer = require '../../server/service/task-sanitizer'
using = require '../common/utils/data-provider'

Task = loopback.getModel 'Task'

describe 'Task', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create()

  afterEach ->
    @sandbox.restore()

  describe 'getStaticCallback', ->
    beforeEach ->
      @callback = sinon.spy()

    it 'should return static tasks', ->
      Task.getStaticCallback @callback
      @callback.should.have.been.calledWithExactly null, ['this', 'illustrate', 'the', 'basic', 'test', 'of', 'a', 'function', 'which', 'uses', 'a', 'callback']

    it 'should return 12 tasks', ->
      Task.getStaticCallback @callback
      @callback.should.have.been.calledWithExactly null, sinon.match (tasks) ->
        tasks.length.should.equal 12

  describe 'getMyTasksCallback', ->
    beforeEach ->
      @sandbox = sinon.sandbox.create()
      @TaskFindStub = @sandbox.stub(Task, 'find').callsArgWith 1, null, ['task1', 'task2']
      @callback = sinon.spy()

    afterEach ->
      @sandbox.restore()

    it 'should fail if find of tasks fails', (done) ->
      @TaskFindStub.callsArgWith 1, 'DB_ERROR'
      Task.getMyTasksCallback null, @callback
      @callback.should.have.been.calledWithExactly 'DB_ERROR'
      done()

    it 'should return task of current user', (done) ->
      Task.getMyTasksCallback 'testCreator', @callback
      Task.find.should.have.been.calledWith where: creator: 'testCreator'
      @callback.should.have.been.calledWithExactly null, ['task1', 'task2']
      done()

  describe 'getMyTasks', ->
    beforeEach ->
      @TaskFindStub = @sandbox.stub(Task, 'find').returns bluebird.resolve ['task1', 'task2']

    it 'should fail if find of tasks fails', (done) ->
      @TaskFindStub.returns bluebird.reject 'DB_ERROR'
      Task.getMyTasks()
      .catch (error) ->
        error.should.equal 'DB_ERROR'
        done()

    it 'should return task of current user', (done) ->
      Task.getMyTasks 'testCreator'
      .then (tasks) ->
        Task.find.should.have.been.calledWithExactly where: creator: 'testCreator'
        tasks.should.deep.equal ['task1', 'task2']
        done()

  describe 'getFilteredTasks', ->
    beforeEach ->
      @TaskFindStub = @sandbox.stub(Task, 'find').returns bluebird.resolve ['task1', 'task2']
      @TaskFilterStub = @sandbox.stub(taskFilter, 'filter').returns bluebird.resolve ['filteredTask1', 'filteredTask2']

    it 'should fail if find of tasks fails', (done) ->
      @TaskFindStub.returns bluebird.reject 'DB_ERROR'
      Task.getMyTasks()
      .catch (error) ->
        error.should.equal 'DB_ERROR'
        done()

    it 'should return task of current user', (done) ->
      Task.getFilteredTasks filter: 'value'
      .then (tasks) ->
        Task.find.should.have.been.calledWithExactly()
        taskFilter.filter.should.have.been.calledWithExactly ['task1', 'task2'], filter: 'value'
        tasks.should.deep.equal ['filteredTask1', 'filteredTask2']
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
      Task.batchDelete 'testCreator', [{id: 1}, {id: 2}, {id: 3}]
      .then (result) ->
        should.not.exist result
        taskAuthorizationChecker.checkTasksAreMine.should.have.been.calledWithExactly 'testCreator', [{id: 1}, {id: 2}, {id: 3}]
        Task.destroyAll.should.have.been.calledWithExactly id: inq: [1, 2, 3]
        done()
