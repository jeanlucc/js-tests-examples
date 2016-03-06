module.exports = (Employee) ->

  Employee.disableRemoteMethod('create', true);
  Employee.disableRemoteMethod('updateAttributes', false);
  Employee.disableRemoteMethod('updateAll', true);

  Employee.disableRemoteMethod('findById', true);
  Employee.disableRemoteMethod('findOne', true);
  Employee.disableRemoteMethod('exists', true);
  Employee.disableRemoteMethod('count', true);

  Employee.disableRemoteMethod('createChangeStream', true);
