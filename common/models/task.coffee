currentUserProvider = require '../../server/service/current-user-provider'

module.exports = (Task) ->

  Task.getMyTasks = (done) ->
    currentUser = currentUserProvider.find()
    return done 'NO_CURRENT_USER' unless currentUser?.id?
    Task.find
      where: ownerId: currentUser.id
      (error, tasks) ->
        return done error if error
        done tasks
