app = require '../../server/server'
currentUserProvider = require '../../server/service/current-user-provider'
loopback = require 'loopback'
should = require('chai').should()
sinon = require 'sinon'
using = require '../common/utils/data-provider'

TaskCallback = app.models.TaskCallback

describe 'TaskCallback', ->
  describe 'getStaticTasks', ->
    it 'should return static tasks', ->
      callback = sinon.spy()
      TaskCallback.getStaticTasks callback
      @callback.should.have.been.calledWithExactly null, ['this', 'illustrate', 'the', 'basic', 'test', 'of', 'a', 'function', 'which', 'uses', 'a', 'callback']

    it 'should return 12 tasks', ->
      callback = sinon.spy()
      TaskCallback.getStaticTasks callback
      @callback.should.have.been.calledWithExactly null, sinon.match (tasks) ->
        tasks.length.should.equal 12

  describe 'getMyTasks', ->
    beforeEach ->
      @currentUserProviderFindStub = sinon.stub(currentUserProvider, 'find').returns id: 42
      @TaskCallbackFindStub = sinon.stub(TaskCallback, 'find').callsArgWith 1, null, ['task1', 'task2']
      @callback = sinon.spy()

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
      TaskCallback.find.should.have.been.calledWith where: owner: 42
      @callback.should.have.been.calledWithExactly null, ['task1', 'task2']
      done()
