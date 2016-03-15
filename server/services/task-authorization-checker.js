var _ = require('lodash');
var bluebird = require('bluebird');
var loopback = require('loopback');

var Task = loopback.getModel('Task');

var checkTasksAreMine = function(creator, tasks) {
  return Task.getMyTasks(creator)
  .then(function(myTasks) {
    var tasksId = _.map(tasks, 'id');
    var myTasksId = _.map(myTasks, 'id');
    var unauthorizedTasksId = _.difference(tasksId, myTasksId);

    if (unauthorizedTasksId.length === 0)
      return bluebird.resolve();
    else
      return bluebird.reject('NOT_MY_TASKS');
  });
};

module.exports = {
  checkTasksAreMine: checkTasksAreMine
};
