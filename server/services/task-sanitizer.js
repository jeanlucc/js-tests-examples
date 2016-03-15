var sanitize = function(task) {
  task.updateDate = new Date();
  if (task.id != null)
    delete task.createDate;
  else
    task.createDate = new Date();
  return task;
};

module.exports = {
  sanitize: sanitize
};
