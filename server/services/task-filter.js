var _ = require('lodash');
var filterValidator = require('./filter-validator');

var filterByCategories = function(categories) {
  return function(task) {
    if(task.categories != null) {
      var taskCategories = task.categories.split(', ')
      return _.some(taskCategories, function(taskCategory) {
        return categories.indexOf(taskCategory) >= 0;
      });
    }
    return false;
  };
};

var filterByCreator = function(creator) {
  return function(task) {
    if(task.creator == null)
      return false
    return task.creator.toLowerCase() === creator.toLowerCase();
  };
};

var filterNotFinishedOnly = function(notFinishedOnly) {
  return function(task) {
    return !(notFinishedOnly && task.status === 'DONE');
  };
};

var registeredFilters = {
  categories: filterByCategories,
  creator: filterByCreator,
  notFinishedOnly: filterNotFinishedOnly
};

var filter = function(tasks, filter) {
  if (tasks == null) {
    return [];
  }
  if (filter == null) {
    return tasks;
  }
  _.forEach(registeredFilters, function(filterFunction, filterKey) {
    if (filterValidator.isFilterValid(filter[filterKey])) {
      tasks = _.filter(tasks, filterFunction(filter[filterKey]));
    }
  });
  return tasks;
};

module.exports = {
  filter: filter
};
