var _ = require('lodash');

var isFilterValid = function(filterValue) {
  return (filterValue != null) && filterValue !== '' && !_.isEqual(filterValue, []);
};

module.exports = {
  isFilterValid: isFilterValid
};
