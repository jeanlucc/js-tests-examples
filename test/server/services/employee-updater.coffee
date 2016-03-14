bluebird = require 'bluebird'
employeeUpdater = require '../../../server/services/employee-updater'
loopback = require 'loopback'

Manager = loopback.getModel 'Manager'
Team = loopback.getModel 'Team'

describe 'employeeUpdater', ->
  describe 'update', ->
    beforeEach ->
      @sandbox = sinon.sandbox.create()
      @ManagerFindByIdStub = @sandbox.stub(Manager, 'findById').returns bluebird.resolve()
      @TeamFindByIdStub = @sandbox.stub(Team, 'findById').returns bluebird.resolve()

    afterEach ->
      @sandbox.restore()

    describe 'updateWithManager', ->
      it 'should fail if find manager fails', (done) ->
        @ManagerFindByIdStub.returns bluebird.reject 'MANAGER_FIND_ERROR'
        employeeUpdater.update managerId: 42, teamId: 51
        .catch (error) ->
          error.should.equal 'MANAGER_FIND_ERROR'
          done()

      it 'should return employee if there is no managerId', (done) ->
        employeeUpdater.update teamId: 51
        .then (employee) ->
          employee.should.deep.equal
            teamId: 51
            teamName: undefined
            departmentName: undefined
            companyName: undefined
          done()

      managerDataProvider = [
        {}
      ,
        manager: id: 51
      ,
        manager: email: 'bobby@theodo.fr', phone: '3333'
        expectedManagerEmail: 'bobby@theodo.fr'
        expectedManagerPhone: '3333'
      ]
      using managerDataProvider, ({manager, expectedManagerEmail, expectedManagerPhone}) ->
        it 'should update employee with manager', (done) ->
          @ManagerFindByIdStub.returns bluebird.resolve manager
          employeeUpdater.update
            managerId: 403
            managerEmail: 'bobby@theodo.fr'
            managerPhone: '3729'
          .then (employee) ->
            Manager.findById.should.have.been.calledWithExactly 403
            assert.equal employee.managerEmail, expectedManagerEmail
            assert.equal employee.managerPhone, expectedManagerPhone
            done()

    describe 'updateWithTeam', ->
      it 'should fail if find team fails', (done) ->
        @TeamFindByIdStub.returns bluebird.reject 'TEAM_FIND_ERROR'
        employeeUpdater.update managerId: 42, teamId: 51
        .catch (error) ->
          error.should.equal 'TEAM_FIND_ERROR'
          done()

      it 'should return employee if there is no teamId', (done) ->
        employeeUpdater.update managerId: 42
        .then (employee) ->
          employee.should.deep.equal
            managerId: 42
            managerEmail: undefined
            managerPhone: undefined
          done()

      teamDataProvider = [
        {}
      ,
        team: id: 51
      ,
        team: name: 'Coinche'
        expectedTeamName: 'Coinche'
      ,
        team: name: 'Coinche', department: id: 51
        expectedTeamName: 'Coinche'
      ,
        team: department: name: 'IT'
        expectedDepartmentName: 'IT'
      ,
        team: name: 'Coinche', department: name: 'IT', company: id: 51
        expectedTeamName: 'Coinche'
        expectedDepartmentName: 'IT'
      ,
        team: department: name: 'IT', company: name: 'Theodo'
        expectedDepartmentName: 'IT'
        expectedCompanyName: 'Theodo'
      ,
        team: name: 'Coinche', department: name: 'IT', company: name: 'Theodo'
        expectedTeamName: 'Coinche'
        expectedDepartmentName: 'IT'
        expectedCompanyName: 'Theodo'
      ]
      using teamDataProvider, ({team, expectedTeamName, expectedDepartmentName, expectedCompanyName}) ->
        it 'should update employee with team', (done) ->
          @TeamFindByIdStub.returns bluebird.resolve toJSON: -> team
          employeeUpdater.update
            teamId: 404
            teamName: 'teamName'
            departmentName: 'departmentName'
            companyName: 'companyName'
          .then (employee) ->
            Team.findById.should.have.been.calledWithExactly 404,
              include: [relation: 'department', scope: include: ['company']]
            assert.deepEqual employee.teamName, expectedTeamName
            assert.deepEqual employee.departmentName, expectedDepartmentName
            assert.deepEqual employee.companyName, expectedCompanyName
            done()
