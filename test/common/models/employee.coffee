bluebird = require 'bluebird'
employeeUpdater = require '../../../server/services/employee-updater'
loopback = require 'loopback'
should = require('chai').should()
sinon = require 'sinon'

Employee = loopback.getModel 'Employee'

describe 'Employee', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create()

  afterEach ->
    @sandbox.restore()

  describe 'safeSave', ->
    beforeEach ->
      @employeeUpdateStub = @sandbox.stub(employeeUpdater, 'update').returns bluebird.resolve id: 51
      @EmployeeUpsertStub = @sandbox.stub(Employee, 'upsert').returns bluebird.resolve id: 24

    it 'should fail if upsert fails', (done) ->
      @EmployeeUpsertStub.returns bluebird.reject 'UPSERT_ERROR'
      Employee.safeSave()
      .catch (error) ->
        error.should.equal 'UPSERT_ERROR'
        done()

    it 'should upsert updated employee', (done) ->
      Employee.safeSave id: 42
      .then (savedEmployee) ->
        employeeUpdater.update.should.have.been.calledWithExactly id: 42
        Employee.upsert.should.have.been.calledWithExactly id: 51
        savedEmployee.should.deep.equal id: 24
        done()
