currentUserProvider = require '../../server/service/current-user-provider'
loopback = require 'loopback'
should = require('chai').should()
sinon = require 'sinon'
using = require '../common/utils/data-provider'

Task = loopback.getModel 'Task'

describe 'Task', ->
  describe 'getMyTasks', ->
    beforeEach ->
      @currentUserProviderFindStub = sinon.stub(currentUserProvider, 'find').returns id: 42
      @TaskFindStub = sinon.stub(Task, 'find').callsArgWith 1, null, ['task1', 'task2']
      @done = sinon.spy()

    noCurrentUserDataProvider = [
      null
      name: 'Bobby'
    ]
    using noCurrentUserDataProvider, (user) ->
      it 'should fail if there is non current user' ->
        @currentUserProviderFindStub.returns user
        Task.getMyTasks @done
        @done.should.have.been.calledWithExactly 'NO_CURRENT_USER'

    it 'should fail if find of tasks fails', ->
      @TaskFindStub.callsArgWith 1, 'DB_ERROR'
      Task.getMyTasks @done
      @done.should.have.been.calledWithExactly 'DB_ERROR'

    it 'should return task of current user', ->
      Task.getMyTasks @done
      @TaskFindStub.should.have.been.calledWith where: owner: 42
      @done.should.have.been.calledWithExactly null, ['task1', 'task2']
