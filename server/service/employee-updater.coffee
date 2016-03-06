_ = require 'lodash'

updateWithManager = (employee, managers) ->
  manager = _.find managers, (currentManager) ->
    currentManager.id is employee.managerId
  employee.managerEmail = manager?.email
  employee.managerPhone = manager?.phone
  employee

updateWithTeam = (employee, teams) ->
  team = _.find teams, (currentTeam) ->
    currentTeam.id is employee.teamId
  employee.departmentName = team?.department?.name
  employee.companyName = team?.department?.company?.name
  employee.groupName = team?.department?.company?.group?.name
  employee

update = (employee, managers, teams) ->
  employee = updateWithManager employee, managers
  updateWithTeam employee, teams

module.exports =
  update: update
