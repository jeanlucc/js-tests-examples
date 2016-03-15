module.exports = function(Team) {
  Team.disableRemoteMethod('create', true);
  Team.disableRemoteMethod('updateAttributes', false);
  Team.disableRemoteMethod('updateAll', true);

  Team.disableRemoteMethod('findById', true);
  Team.disableRemoteMethod('findOne', true);
  Team.disableRemoteMethod('exists', true);
  Team.disableRemoteMethod('count', true);

  Team.disableRemoteMethod('createChangeStream', true);

  Team.disableRemoteMethod('__get__department', false);
}
