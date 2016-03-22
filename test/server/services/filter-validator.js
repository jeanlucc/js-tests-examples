var filterValidator = require('../../../server/services/filter-validator');

describe('filterValidator', function() {
  describe('isFilterValid', function() {
    var filterProvider = [
      {isValid: false},
      {filterValue: null, isValid: false},
      {filterValue: [], isValid: false},
      {filterValue: '', isValid: false},
      {filterValue: true, isValid: true},
      {filterValue: false, isValid: true},
      {filterValue: 0, isValid: true},
      {filterValue: 1, isValid: true},
      {filterValue: 'toto', isValid: true},
      {filterValue: ['toto'], isValid: true},
      {filterValue: [{filterName: 'toto'}], isValid: true}
    ]
    using(filterProvider, function(args) {
      it('should check if filter is valid', function() {
        filterValidator.isFilterValid(args.filterValue).should.equal(args.isValid);
      });
    });
  });
});
