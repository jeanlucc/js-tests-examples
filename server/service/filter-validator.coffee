_ = require 'lodash'

isFilterValid = (filterValue) ->
  filterValue? and filterValue isnt '' and not _.isEqual filterValue, []

module.exports =
  isFilterValid: isFilterValid
