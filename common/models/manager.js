module.exports = function(Manager) {
  Manager.disableRemoteMethod('create', true);
  Manager.disableRemoteMethod('updateAttributes', false);
  Manager.disableRemoteMethod('updateAll', true);

  Manager.disableRemoteMethod('findById', true);
  Manager.disableRemoteMethod('findOne', true);
  Manager.disableRemoteMethod('exists', true);
  Manager.disableRemoteMethod('count', true);

  Manager.disableRemoteMethod('createChangeStream', true);
}
