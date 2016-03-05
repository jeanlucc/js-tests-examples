currentUserProvider = require '../../server/service/current-user-provider'

module.exports = (Task) ->

  Task.getStaticTasks = (done) ->
    done null, ['this', 'illustrate', 'the', 'basic', 'test', 'of', 'a', 'function', 'which', 'uses', 'a', 'callback']

  Task.getMyTasks = (done) ->
    currentUser = currentUserProvider.find()
    return done 'NO_CURRENT_USER' unless currentUser?.id?
    Task.find
      where: ownerId: currentUser.id
      (error, tasks) ->
        return done error if error
        done tasks
