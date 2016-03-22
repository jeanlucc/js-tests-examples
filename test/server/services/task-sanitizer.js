var moment = require('moment');
var taskSanitizer = require('../../../server/services/task-sanitizer');

describe('taskSanitizer', function() {
  beforeEach(function() {
    this.sandbox = sinon.sandbox.create();
    this.sandbox.stub(Date, 'now').returns('NOW!');
  });

  afterEach(function() {
    this.sandbox.restore();
  });

  describe('sanitize', function() {
    it('should update information and delete immutable fields for edition', function() {
      taskSanitizer.sanitize({id: 42, createDate: '13-11-1128', updateDate: '27-08-1982'})
        .should.deep.equal({updateDate: 'NOW!', id: 42});
    });

    it('should add information for creation', function() {
      taskSanitizer.sanitize({}).should.deep.equal({createDate: 'NOW!', updateDate: 'NOW!'});
    });
  });
});
