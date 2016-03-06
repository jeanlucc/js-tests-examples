assert = require('chai').assert
employeeUpdater = require '../../server/service/employee-updater'
using = require '../common/utils/data-provider'

describe 'employeeUpdater', ->
  describe 'update', ->
    beforeEach ->
      @employee =
        managerId: 403
        teamId: 404
        managerEmail: 'bobby@theodo.fr'
        managerPhone: '3729'
        departmentName: 'departmentName'
        companyName: 'companyName'
        groupName: 'groupName'

    describe 'updateWithManager', ->
      managerDataProvider = [
        {list: null}
        {list: []}
        {
          list: [
            {id: 1}
            {id: 2}
            {id: 3}
          ]
        }
        {
          list: [
            {id: 402, managerEmail: 'bob@theodo.fr', managerPhone: '3131'}
            {id: 403, managerEmail: 'fred@theodo.fr', managerPhone: '3232'}
            {id: 404, managerEmail: 'alice@theodo.fr', managerPhone: '3333'}
          ]
          expectedManagerEmail: 'fred@theodo.fr'
          expectedManagerPhone: '3232'
        }
      ]
      using managerDataProvider, (data) ->
        it 'should update employee with manager', ->
          employee = employeeUpdater.update @employee, data.list
          assert.equal employee.min, data.expectedMin
          assert.equal employee.max, data.expectedMax

    describe 'updateWithTeam', ->
      teamDataProvider = [
        {list: null}
        {list: []}
        {
          list: [
            {id: 1}
            {id: 2}
            {id: 3}
          ]
        }
        {
          list: [
            {id: 402}
            {id: 403}
            {id: 404}
          ]
        }
        {
          list: [
            {id: 402, department: name: 'contracting'}
            {id: 403, department: name: 'purchasing'}
            {id: 404, department: name: 'IT'}
          ]
          expectedDepartmentName: 'IT'
        }
        {
          list: [
            {id: 402, department: name: 'contracting', company: name: 'Theodo UK'}
            {id: 403, department: name: 'purchasing', company: name: 'BAM'}
            {id: 404, department: name: 'IT', company: name: 'Theodo'}
          ]
          expectedDepartmentName: 'IT'
          expectedCompanyName: 'Theodo'
        }
        {
          list: [
            {id: 402, department: name: 'contracting', company: name: 'Theodo UK', group: name: 'Google'}
            {id: 403, department: name: 'purchasing', company: name: 'BAM', group: name: 'Apple'}
            {id: 404, department: name: 'IT', company: name: 'Theodo', group: name: 'Theodo Academy'}
          ]
          expectedDepartmentName: 'IT'
          expectedCompanyName: 'Theodo'
          expectedGroupName: 'Theodo Academy'
        }
      ]
      using teamDataProvider, (data, index) ->
        it 'should update employee, company, group with team', ->
          employee = employeeUpdater.update @employee, null, data.list
          assert.deepEqual employee.department, data.expectedDepartment
          assert.deepEqual employee.company, data.expectedCompany
          assert.deepEqual employee.group, data.expectedGroup
