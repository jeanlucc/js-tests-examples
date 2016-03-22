var sanitize = function(task) {
  task.updateDate = Date.now();
  if (task.id != null)
    delete task.createDate;
  else
    task.createDate = Date.now();
  return task;
};

module.exports = {
  sanitize: sanitize
};
