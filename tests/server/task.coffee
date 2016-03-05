currentUserProvider = require '../../server/service/current-user-provider'
loopback = require 'loopback'
should = require('chai').should()
sinon = require 'sinon'
using = require '../common/utils/data-provider'

Task = loopback.getModel 'Task'

describe 'Task', ->
  describe 'getStaticTasks', ->
    it 'should return static tasks', ->
      callback = sinon.spy()
      Task.getStaticTasks callback
      @callback.should.have.been.calledWithExactly null, ['this', 'illustrate', 'the', 'basic', 'test', 'of', 'a', 'function', 'which', 'uses', 'a', 'callback']

    it 'should return 12 tasks', ->
      callback = sinon.spy()
      Task.getStaticTasks callback
      @callback.should.have.been.calledWithExactly null, sinon.match (tasks) ->
        tasks.length.should.equal 12

  describe 'getMyTasks', ->
    beforeEach ->
      @currentUserProviderFindStub = sinon.stub(currentUserProvider, 'find').returns id: 42
      @TaskFindStub = sinon.stub(Task, 'find').callsArgWith 1, null, ['task1', 'task2']
      @callback = sinon.spy()

    noCurrentUserDataProvider = [
      null
      name: 'Bobby'
    ]
    using noCurrentUserDataProvider, (user) ->
      it 'should fail if there is non current user' ->
        @currentUserProviderFindStub.returns user
        Task.getMyTasks @callback
        @callback.should.have.been.calledWithExactly 'NO_CURRENT_USER'

    it 'should fail if find of tasks fails', ->
      @TaskFindStub.callsArgWith 1, 'DB_ERROR'
      Task.getMyTasks @callback
      @callback.should.have.been.calledWithExactly 'DB_ERROR'

    it 'should return task of current user', ->
      Task.getMyTasks @callback
      @TaskFindStub.should.have.been.calledWith where: owner: 42
      @callback.should.have.been.calledWithExactly null, ['task1', 'task2']
