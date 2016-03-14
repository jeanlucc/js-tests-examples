_ = require 'lodash'
filterValidator = require './filter-validator'

filterByCategories = (categories) ->
  (task) ->
    taskCategories = task.categories?.split ', '
    _.some taskCategories, (category) -> category in categories

filterByCreator = (creator) ->
  (task) ->
    task.creator?.toLowerCase() is creator.toLowerCase()

filterNotFinishedOnly = (notFinishedOnly) ->
  (task) ->
    not (notFinishedOnly and task.status is 'DONE')

registeredFilters =
  categories: filterByCategories
  creator: filterByCreator
  notFinishedOnly: filterNotFinishedOnly

filter = (tasks, filter) ->
  return [] unless tasks?
  return tasks unless filter?
  _.forEach registeredFilters, (filterFunction, filterKey) ->
    if filterValidator.isFilterValid filter[filterKey]
      tasks = _.filter tasks, filterFunction filter[filterKey]
  tasks

module.exports =
  filter: filter
