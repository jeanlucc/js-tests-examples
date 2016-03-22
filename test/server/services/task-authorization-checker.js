var bluebird = require('bluebird');
var loopback = require('loopback');
var taskAuthorizationChecker = require('../../../server/services/task-authorization-checker');

var Task = loopback.getModel('Task');

describe('taskAuthorizationChecker', function() {
  beforeEach(function() {
    this.sandbox = sinon.sandbox.create();
  });

  afterEach(function() {
    this.sandbox.restore();
  });

  describe('checkTasksAreMine', function() {
    it('should fail if getMyTasks fails', function(done) {
      this.sandbox.stub(Task, 'getMyTasks').returns(bluebird.reject('DB_ERROR'));
      taskAuthorizationChecker.checkTasksAreMine()
      .catch(function(error) {
        error.should.equal('DB_ERROR');
        done();
      });
    });

    var tasksDataProvider = _.map([
      {
        tasks: [1],
        myTasks: [],
        authorized: false
      }, {
        tasks: [1],
        myTasks: null,
        authorized: false
      }, {
        tasks: [1],
        authorized: false
      }, {
        tasks: [1, 2, 4],
        myTasks: [1, 2, 3],
        authorized: false
      }, {
        tasks: [1, 2, 3, 4],
        myTasks: [1, 2, 3],
        authorized: false
      }, {
        tasks: [],
        myTasks: [],
        authorized: true
      }, {
        tasks: [2],
        myTasks: [1, 2, 3],
        authorized: true
      }, {
        tasks: [1, 2],
        myTasks: [1, 2, 3],
        authorized: true
      }, {
        tasks: [1, 2, 3],
        myTasks: [1, 2, 3],
        authorized: true
      }
    ], function(testCase) {
      testCase.tasks = _.map(testCase.tasks, function(id) {return {id: id};});
      testCase.myTasks = _.map(testCase.myTasks, function(id) {return {id: id};});
      return testCase;
    });

    using(tasksDataProvider, function(args) {
      it('should be rejected when a task is not one of mine, fulfilled otherwise', function(done) {
        this.sandbox.stub(Task, 'getMyTasks').returns(bluebird.resolve(args.myTasks));

        var promise = taskAuthorizationChecker.checkTasksAreMine('testCreator', args.tasks)
        if(args.authorized) {
          promise.then(function() {
            Task.getMyTasks.should.have.been.calledWithExactly('testCreator');
            done();
          });
        } else {
          promise.catch(function(error) {
            Task.getMyTasks.should.have.been.calledWithExactly('testCreator');
            error.should.equal('NOT_MY_TASKS');
            done();
          });
        }
      });
    });
  });
});
