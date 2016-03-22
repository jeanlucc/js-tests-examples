var bluebird = require('bluebird');
var employeeUpdater = require('../../../server/services/employee-updater');
var loopback = require('loopback');

var Manager = loopback.getModel('Manager');
var Team = loopback.getModel('Team');

describe('employeeUpdater', function() {
  describe('update', function() {
    beforeEach(function() {
      this.sandbox = sinon.sandbox.create();
      this.ManagerFindByIdStub = this.sandbox.stub(Manager, 'findById').returns(bluebird.resolve());
      this.TeamFindByIdStub = this.sandbox.stub(Team, 'findById').returns(bluebird.resolve());
    });

    afterEach(function() {
      this.sandbox.restore();
    });

    describe('updateWithManager', function() {
      it('should fail if find manager fails', function(done) {
        this.ManagerFindByIdStub.returns(bluebird.reject('MANAGER_FIND_ERROR'));
        employeeUpdater.update({
          managerId: 42,
          teamId: 51
        })
        .catch(function(error) {
          error.should.equal('MANAGER_FIND_ERROR');
          done();
        });
      });

      it('should return employee if there is no managerId', function(done) {
        employeeUpdater.update({
          teamId: 51
        })
        .then(function(employee) {
          employee.should.deep.equal({
            teamId: 51,
            teamName: undefined,
            departmentName: undefined,
            companyName: undefined
          });
          done();
        });
      });

      var managerDataProvider = [
        {},
        {
          manager: {id: 51}
        },
        {
          manager: {email: 'bobby@theodo.fr', phone: '3333'},
          expectedManagerEmail: 'bobby@theodo.fr',
          expectedManagerPhone: '3333'
        }
      ];

      using(managerDataProvider, function(args) {
        it('should update employee with manager', function(done) {
          this.ManagerFindByIdStub.returns(bluebird.resolve(args.manager));
          employeeUpdater.update({
            managerId: 403,
            managerEmail: 'bobby@theodo.fr',
            managerPhone: '3729'
          })
          .then(function(employee) {
            Manager.findById.should.have.been.calledWithExactly(403);
            assert.equal(employee.managerEmail, args.expectedManagerEmail);
            assert.equal(employee.managerPhone, args.expectedManagerPhone);
            done();
          });
        });
      });
    });

    describe('updateWithTeam', function() {
      it('should fail if find team fails', function(done) {
        this.TeamFindByIdStub.returns(bluebird.reject('TEAM_FIND_ERROR'));
        employeeUpdater.update({
          managerId: 42,
          teamId: 51
        })
        .catch(function(error) {
          error.should.equal('TEAM_FIND_ERROR');
          done();
        });
      });

      it('should return employee if there is no teamId', function(done) {
        employeeUpdater.update({
          managerId: 42
        })
        .then(function(employee) {
          employee.should.deep.equal({
            managerId: 42,
            managerEmail: undefined,
            managerPhone: undefined
          });
          done();
        });
      });

      var teamDataProvider = [
        {},
        {
          team: {id: 51}
        },
        {
          team: {name: 'Coinche'},
          expectedTeamName: 'Coinche'
        },
        {
          team: {name: 'Coinche', department: {id: 51}},
          expectedTeamName: 'Coinche'
        },
        {
          team: {department: {name: 'IT'}},
          expectedDepartmentName: 'IT'
        },
        {
          team: {name: 'Coinche', department: {name: 'IT', company: {id: 51}}},
          expectedTeamName: 'Coinche',
          expectedDepartmentName: 'IT'
        },
        {
          team: {department: {name: 'IT', company: {name: 'Theodo'}}},
          expectedDepartmentName: 'IT',
          expectedCompanyName: 'Theodo'
        },
        {
          team: {name: 'Coinche',department: {name: 'IT', company: {name: 'Theodo'}}},
          expectedTeamName: 'Coinche',
          expectedDepartmentName: 'IT',
          expectedCompanyName: 'Theodo'
        }
      ];

      using(teamDataProvider, function(args) {
        it('should update employee with team', function(done) {
          this.TeamFindByIdStub.returns(bluebird.resolve({
            toJSON: function() {
              return args.team;
            }
          }));

          employeeUpdater.update({
            teamId: 404,
            teamName: 'teamName',
            departmentName: 'departmentName',
            companyName: 'companyName'
          })
          .then(function(employee) {
            Team.findById.should.have.been.calledWithExactly(404, {
              include: [
                {
                  relation: 'department',
                  scope: {
                    include: ['company']
                  }
                }
              ]
            });
            assert.deepEqual(employee.teamName, args.expectedTeamName);
            assert.deepEqual(employee.departmentName, args.expectedDepartmentName);
            assert.deepEqual(employee.companyName, args.expectedCompanyName);
            done();
          });
        });
      });
    });
  });
});
