module.exports = (Department) ->

  Department.disableRemoteMethod('create', true);
  Department.disableRemoteMethod('updateAttributes', false);
  Department.disableRemoteMethod('updateAll', true);

  Department.disableRemoteMethod('findById', true);
  Department.disableRemoteMethod('findOne', true);
  Department.disableRemoteMethod('exists', true);
  Department.disableRemoteMethod('count', true);

  Department.disableRemoteMethod('createChangeStream', true);

  Department.disableRemoteMethod('__get__company', false);
