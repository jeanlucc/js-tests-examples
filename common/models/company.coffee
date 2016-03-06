module.exports = (Company) ->

  Company.disableRemoteMethod('create', true);
  Company.disableRemoteMethod('updateAttributes', false);
  Company.disableRemoteMethod('updateAll', true);

  Company.disableRemoteMethod('findById', true);
  Company.disableRemoteMethod('findOne', true);
  Company.disableRemoteMethod('exists', true);
  Company.disableRemoteMethod('count', true);

  Company.disableRemoteMethod('createChangeStream', true);
