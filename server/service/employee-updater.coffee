bluebird = require 'bluebird'
loopback = require 'loopback'

Manager = loopback.getModel 'Manager'
Team = loopback.getModel 'Team'

updateWithManager = (employee) ->
  return bluebird.resolve employee unless employee.managerId?
  Manager.findById employee.managerId
  .then (manager) ->
    employee.managerEmail = manager?.email
    employee.managerPhone = manager?.phone
    employee

updateWithTeam = (employee) ->
  return bluebird.resolve employee unless employee.teamId?
  Team.findById employee.teamId,
    include: [relation: 'department', scope: include: ['company']]
  .then (team) ->
    team = team?.toJSON()
    employee.teamName = team?.name
    employee.departmentName = team?.department?.name
    employee.companyName = team?.department?.company?.name
    employee

update = (employee) ->
  employee = employee or {}
  updateWithManager employee
  .then (employee) ->
    updateWithTeam employee

module.exports =
  update: update
