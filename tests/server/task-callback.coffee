app = require '../../server/server'
chai = require 'chai'
currentUserProvider = require '../../server/service/current-user-provider'
loopback = require 'loopback'
should = require('chai').should()
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
using = require '../common/utils/data-provider'

chai.use sinonChai

TaskCallback = app.models.TaskCallback

describe 'TaskCallback', ->
  describe 'getStaticTasks', ->
    beforeEach ->
      @callback = sinon.spy()

    it 'should return static tasks', ->
      TaskCallback.getStaticTasks @callback
      @callback.should.have.been.calledWithExactly null, ['this', 'illustrate', 'the', 'basic', 'test', 'of', 'a', 'function', 'which', 'uses', 'a', 'callback']

    it 'should return 12 tasks', ->
      TaskCallback.getStaticTasks @callback
      @callback.should.have.been.calledWithExactly null, sinon.match (tasks) ->
        tasks.length.should.equal 12

  describe 'getMyTasks', ->
    beforeEach ->
      @sandbox = sinon.sandbox.create()
      @currentUserProviderFindStub = @sandbox.stub(currentUserProvider, 'find').returns id: 42
      @TaskCallbackFindStub = @sandbox.stub(TaskCallback, 'find').callsArgWith 1, null, ['task1', 'task2']
      @callback = sinon.spy()

    afterEach ->
      @sandbox.restore()

    noCurrentUserDataProvider = [
      null
      name: 'Bobby'
    ]
    using noCurrentUserDataProvider, (user) ->
      it 'should fail if there is no current user', (done) ->
        @currentUserProviderFindStub.returns user
        TaskCallback.getMyTasks @callback
        @callback.should.have.been.calledWithExactly 'NO_CURRENT_USER'
        done()

    it 'should fail if find of tasks fails', (done) ->
      @TaskCallbackFindStub.callsArgWith 1, 'DB_ERROR'
      TaskCallback.getMyTasks @callback
      @callback.should.have.been.calledWithExactly 'DB_ERROR'
      done()

    it 'should return task of current user', (done) ->
      TaskCallback.getMyTasks @callback
      TaskCallback.find.should.have.been.calledWith where: ownerId: 42
      @callback.should.have.been.calledWithExactly null, ['task1', 'task2']
      done()
