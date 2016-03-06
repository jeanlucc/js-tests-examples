employeeUpdater = require '../../server/service/employee-updater'

module.exports = (Employee) ->

  Employee.disableRemoteMethod('create', true);
  Employee.disableRemoteMethod('updateAttributes', false);
  Employee.disableRemoteMethod('updateAll', true);

  Employee.disableRemoteMethod('findById', true);
  Employee.disableRemoteMethod('findOne', true);
  Employee.disableRemoteMethod('exists', true);
  Employee.disableRemoteMethod('count', true);

  Employee.disableRemoteMethod('createChangeStream', true);

  Employee.safeSave = (employee) ->
    employeeUpdater.update employee
    .then (employee) ->
      Employee.upsert employee

  Employee.remoteMethod 'safeSave',
    accepts: [{arg: 'employee', type: 'object', required: true, http: source: 'body'}]
    returns: [{type: 'object', root: true}]
    http:
      verb: 'PUT'
      path: '/safe-save'
    description: 'save the employee with the information of its hierarchy'
