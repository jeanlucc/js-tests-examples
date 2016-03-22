var bluebird = require('bluebird');
var loopback = require('loopback');
var taskAuthorizationChecker = require('../../../server/services/task-authorization-checker');
var taskFilter = require('../../../server/services/task-filter');
var taskSanitizer = require('../../../server/services/task-sanitizer');

var Task = loopback.getModel('Task');

describe('Task', function() {
  beforeEach(function() {
    this.sandbox = sinon.sandbox.create();
  });

  afterEach(function() {
    this.sandbox.restore();
  });

  describe('getStaticCallback', function() {
    beforeEach(function() {
      this.callback = sinon.spy();
    });

    it('should return static tasks', function() {
      Task.getStaticCallback(this.callback);
      this.callback.should.have.been.calledWithExactly(null, ['this', 'illustrate', 'the', 'basic', 'test', 'of', 'a', 'function', 'which', 'uses', 'a', 'callback']);
    });

    it('should return 12 tasks', function() {
      Task.getStaticCallback(this.callback);
      this.callback.should.have.been.calledWithExactly(null, sinon.match(function(tasks) {
        return tasks.length.should.equal(12);
      }));
    });
  });

  describe('getMyTasksCallback', function() {
    beforeEach(function() {
      this.TaskFindStub = this.sandbox.stub(Task, 'find').callsArgWith(1, null, ['task1', 'task2']);
      this.callback = sinon.spy();
    });

    it('should fail if find of tasks fails', function(done) {
      this.TaskFindStub.callsArgWith(1, 'DB_ERROR');
      Task.getMyTasksCallback(null, this.callback);
      this.callback.should.have.been.calledWithExactly('DB_ERROR');
      done();
    });

    it('should return task of current user', function(done) {
      Task.getMyTasksCallback('testCreator', this.callback)
      Task.find.should.have.been.calledWith({where: {creator: 'testCreator'}});
      this.callback.should.have.been.calledWithExactly(null, ['task1', 'task2']);
      done();
    });
  });

  describe('getMyTasks', function() {
    beforeEach(function() {
      this.TaskFindStub = this.sandbox.stub(Task, 'find').returns(bluebird.resolve(['task1', 'task2']));
    });

    it('should fail if find of tasks fails', function(done) {
      this.TaskFindStub.returns(bluebird.reject('DB_ERROR'));
      Task.getMyTasks()
      .catch(function(error) {
        error.should.equal('DB_ERROR');
        done();
      });
    });

    it('should return task of current user', function(done) {
      Task.getMyTasks('testCreator')
      .then(function(tasks) {
        Task.find.should.have.been.calledWithExactly({where: {creator: 'testCreator'}});
        tasks.should.deep.equal(['task1', 'task2']);
        done();
      });
    });
  });

  describe('getFilteredTasks', function() {
    beforeEach(function() {
      this.TaskFindStub = this.sandbox.stub(Task, 'find').returns(bluebird.resolve(['task1', 'task2']));
      this.TaskFilterStub = this.sandbox.stub(taskFilter, 'filter').returns(bluebird.resolve(['filteredTask1', 'filteredTask2']));
    });

    it('should fail if find of tasks fails', function(done) {
      this.TaskFindStub.returns(bluebird.reject('DB_ERROR'));
      Task.getMyTasks()
      .catch(function(error) {
        error.should.equal('DB_ERROR');
        done();
      });
    });

    it('should return task of current user', function(done) {
      Task.getFilteredTasks({filter: 'value'})
      .then(function(tasks) {
        Task.find.should.have.been.calledWithExactly()
        taskFilter.filter.should.have.been.calledWithExactly(['task1', 'task2'], {filter: 'value'});
        tasks.should.deep.equal(['filteredTask1', 'filteredTask2']);
        done();
      });
    });
  });

  describe('safeSave', function() {
    beforeEach(function() {
      this.taskSanitizerStub = this.sandbox.stub(taskSanitizer, 'sanitize').returns({id: 51, date: '15-11-1240'});
      this.TaskUpsertStub = this.sandbox.stub(Task, 'upsert').returns(bluebird.resolve({id: 24}));
    });

    it('should fail if upsert fails', function(done) {
      this.TaskUpsertStub.returns(bluebird.reject('UPSERT_ERROR'));
      Task.safeSave()
      .catch(function(error) {
        error.should.equal('UPSERT_ERROR');
        done();
      });
    });

    it('should upsert sanitized task', function(done) {
      Task.safeSave({id: 42})
      .then(function(savedTask) {
        taskSanitizer.sanitize.should.have.been.calledWithExactly({id: 42});
        Task.upsert.should.have.been.calledWithExactly({id: 51, date: '15-11-1240'});
        savedTask.should.deep.equal({id: 24});
        done();
      });
    });
  });

  describe('batchDelete', function() {
    beforeEach(function() {
      this.checkTasksAreMineStub = this.sandbox.stub(taskAuthorizationChecker, 'checkTasksAreMine').returns(bluebird.resolve());
      this.TaskDestroyAllStub = this.sandbox.stub(Task, 'destroyAll').returns(bluebird.resolve());
    });

    it('should fail if user has no authorization', function(done) {
      this.checkTasksAreMineStub.returns(bluebird.reject('AUTHORIZATION_ERROR'));
      Task.batchDelete()
      .catch(function(error) {
        error.should.equal('AUTHORIZATION_ERROR');
        done();
      });
    });

    it('should fail if destroyAll fails', function(done) {
      this.TaskDestroyAllStub.returns(bluebird.reject('DB_ERROR'));
      Task.batchDelete()
      .catch(function(error) {
        error.should.equal('DB_ERROR');
        done();
      });
    });

    it('should destroyAll', function(done) {
      Task.batchDelete('testCreator', [{id: 1}, {id: 2}, {id: 3}])
      .then(function(result) {
        should.not.exist(result);
        taskAuthorizationChecker.checkTasksAreMine.should.have.been.calledWithExactly('testCreator', [{id: 1}, {id: 2}, {id: 3}]);
        Task.destroyAll.should.have.been.calledWithExactly({id: {inq: [1, 2, 3]}});
        done();
      });
    });
  });
});
