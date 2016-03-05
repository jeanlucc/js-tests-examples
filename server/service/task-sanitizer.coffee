sanitize = (task) ->
  task.updateDate = new Date()

  if task.id?
    delete task.createDate
  else
    task.createDate = new Date()

  task

module.exports =
  sanitize: sanitize
