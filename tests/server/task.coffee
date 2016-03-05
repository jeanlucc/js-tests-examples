bluebird = require 'bluebird'
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
      @TaskFindStub = sinon.stub(Task, 'find').returns bluebird.resolve ['task1', 'task2']

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

    it 'should return task of current user', ->
      Task.getMyTasks()
      .then (tasks) ->
        Task.find.should.have.been.calledWithExactly where: owner: 42
        tasks.should.deep.equal ['task1', 'task2']
        done()

  describe 'batchDelete', ->
