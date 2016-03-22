var _ = require('lodash');
var bluebird = require('bluebird');
var taskAuthorizationChecker = require('../../server/services/task-authorization-checker');
var taskFilter = require('../../server/services/task-filter');
var taskSanitizer = require('../../server/services/task-sanitizer');

module.exports = function(Task) {

  Task.disableRemoteMethod('create', true);
  Task.disableRemoteMethod('updateAttributes', false);
  Task.disableRemoteMethod('updateAll', true);

  Task.disableRemoteMethod('findById', true);
  Task.disableRemoteMethod('findOne', true);
  Task.disableRemoteMethod('exists', true);
  Task.disableRemoteMethod('count', true);

  Task.disableRemoteMethod('__get__owner', false);
  Task.disableRemoteMethod('createChangeStream', true);

  Task.getStaticCallback = function(done) {
    done(null, ['this', 'illustrate', 'the', 'basic', 'test', 'of', 'a', 'function', 'which', 'uses', 'a', 'callback']);
  };

  Task.getMyTasksCallback = function(creator, done) {
    Task.find({where: {creator: creator}}, function(error, tasks) {
      if (error) {
        return done(error);
      }
      done(null, tasks);
    });
  };

  Task.getMyTasks = function(creator) {
    return Task.find({where: {creator: creator}});
  };

  Task.getFilteredTasks = function(filter) {
    return Task.find().then(function(allTasks) {
      return taskFilter.filter(allTasks, filter);
    });
  };

  Task.safeSave = function(task) {
    var taskToUpdate = taskSanitizer.sanitize(task);
    return Task.upsert(taskToUpdate);
  };

  Task.batchDelete = function(creator, tasks) {
    return taskAuthorizationChecker.checkTasksAreMine(creator, tasks)
    .then(function() {
      return Task.destroyAll({id: {inq: _.map(tasks, 'id')}});
    });
  };

  Task.remoteMethod('getStaticCallback', {
    returns: [{type: 'array', root: true}],
    http: {verb: 'GET', path: '/static'},
    description: 'return a static array of strings to have the simplest example of code wih callback'
  });

  Task.remoteMethod('getMyTasksCallback', {
    accepts: [{arg: 'creator', type: 'string', required: true, http: {source: 'path'}}],
    returns: [{type: 'array', root: true}],
    http: {verb: 'GET', path: '/my-tasks-callback/:creator'},
    description: 'return the tasks of given creator using callback syntax'
  });

  Task.remoteMethod('getMyTasks', {
    accepts: [{arg: 'creator', type: 'string', required: true, http: {source: 'path'}}],
    returns: [{type: 'array', root: true}],
    http: {verb: 'GET', path: '/my-tasks/:creator'},
    description: 'return the tasks of given creator using promise syntax'
  });

  Task.remoteMethod('getFilteredTasks', {
    accepts: [{arg: 'filter', type: 'object', http: {source: 'query'}}],
    returns: [{type: 'array', root: true}],
    http: {verb: 'GET', path: '/filtered-tasks'},
    description: 'return the tasks filtered with given argument'
  });

  Task.remoteMethod('safeSave', {
    accepts: [{arg: 'task', type: 'object', required: true, http: {source: 'body'}}],
    returns: [{type: 'object', root: true}],
    http: {verb: 'PUT', path: '/safe-save'},
    description: 'save the task with the creation and update date of server'
  });

  Task.remoteMethod('batchDelete', {
    accepts: [
      {arg: 'creator', type: 'string', required: true, http: {source: 'path'}},
      {arg: 'tasks', type: 'array', required: true, http: {source: 'body'}}
    ],
    http: {verb: 'PUT', path: '/batch-delete/:creator'},
    description: 'delete given tasks if they creator match given creator'
  });
}
