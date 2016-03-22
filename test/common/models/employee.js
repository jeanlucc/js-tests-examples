var bluebird = require('bluebird');
var employeeUpdater = require('../../../server/services/employee-updater');
var loopback = require('loopback');

var Employee = loopback.getModel('Employee');

describe('Employee', function() {
  beforeEach(function() {
    this.sandbox = sinon.sandbox.create();
  });

  afterEach(function() {
    this.sandbox.restore();
  });

  describe('safeSave', function() {
    beforeEach(function() {
      this.employeeUpdateStub = this.sandbox.stub(employeeUpdater, 'update').returns(bluebird.resolve({id: 51}));
      this.EmployeeUpsertStub = this.sandbox.stub(Employee, 'upsert').returns(bluebird.resolve({id: 24}));
    });

    it('should fail if upsert fails', function(done) {
      this.EmployeeUpsertStub.returns(bluebird.reject('UPSERT_ERROR'));
      Employee.safeSave()
      .catch(function(error) {
        error.should.equal('UPSERT_ERROR');
        done();
      });
    });

    it('should upsert updated employee', function(done) {
      Employee.safeSave({id: 42})
      .then(function(savedEmployee) {
        employeeUpdater.update.should.have.been.calledWithExactly({id: 42});
        Employee.upsert.should.have.been.calledWithExactly({id: 51});
        savedEmployee.should.deep.equal({id: 24});
        done();
      });
    });
  });
});
