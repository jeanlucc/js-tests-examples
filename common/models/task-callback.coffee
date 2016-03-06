currentUserProvider = require '../../server/service/current-user-provider'

module.exports = (TaskCallback) ->

  TaskCallback.disableRemoteMethod('create', true);
  TaskCallback.disableRemoteMethod('updateAttributes', false);
  TaskCallback.disableRemoteMethod('updateAll', true);

  TaskCallback.disableRemoteMethod('findById', true);
  TaskCallback.disableRemoteMethod('findOne', true);
  TaskCallback.disableRemoteMethod('exists', true);
  TaskCallback.disableRemoteMethod('count', true);

  TaskCallback.disableRemoteMethod('deleteById', true);

  TaskCallback.disableRemoteMethod('__get__owner', false);
  TaskCallback.disableRemoteMethod('createChangeStream', true);

  TaskCallback.getStaticTasks = (done) ->
    done null, ['this', 'illustrate', 'the', 'basic', 'test', 'of', 'a', 'function', 'which', 'uses', 'a', 'callback']

  TaskCallback.getMyTasks = (done) ->
    currentUser = currentUserProvider.find()
    return done 'NO_CURRENT_USER' unless currentUser?.id?
    TaskCallback.find
      where: ownerId: currentUser.id
      (error, tasks) ->
        return done error if error
        done null, tasks
