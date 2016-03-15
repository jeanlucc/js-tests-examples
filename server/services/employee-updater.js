var bluebird = require('bluebird');
var loopback = require('loopback');

var Manager = loopback.getModel('Manager');
var Team = loopback.getModel('Team');

updateWithManager = function(employee) {
  if (employee.managerId == null)
    return bluebird.resolve(employee);

  Manager.findById(employee.managerId)
  .then(function(manager) {
    if(manager != null) {
      employee.managerEmail = manager.email;
      employee.managerPhone = manager.phone;
    }
    return employee;
  });
};

updateWithTeam = function(employee) {
  if (employee.teamId == null)
    return bluebird.resolve(employee);

  Team.findById(employee.teamId, {
    include: [
      {
        relation: 'department',
        scope: {
          include: ['company']
        }
      }
    ]
  }).then(function(team) {
    if(team != null) {
      team = team.toJSON();
    }
    if(team != null) {
      employee.teamName = team.name;
      if(team.department != null) {
        employee.departmentName = team.department.name;
        if(team.department.company != null)
          employee.companyName = team.department.company.name;
      }
    }
    return employee;
  });
};

update = function(employee) {
  employee = employee || {};
  updateWithManager(employee)
  .then(function(employee) {
    return updateWithTeam(employee);
  });
};

module.exports = {
  update: update
};
