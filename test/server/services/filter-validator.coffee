should = require('chai').should()
filterValidator = require '../../../server/services/filter-validator'
using = require '../../common/utils/data-provider'

describe 'filterValidator', ->
  describe 'isFilterValid', ->
    filterProvider = [
      {isValid: false}
      {filterValue: null, isValid: false}
      {filterValue: [], isValid: false}
      {filterValue: '', isValid: false}
      {filterValue: true, isValid: true}
      {filterValue: false, isValid: true}
      {filterValue: 0, isValid: true}
      {filterValue: 1, isValid: true}
      {filterValue: 'toto', isValid: true}
      {filterValue: ['toto'], isValid: true}
      {filterValue: [filterName: 'toto'], isValid: true}
    ]
    using filterProvider, ({filterValue, isValid}) ->
      it 'should check if filter is valid', ->
        filterValidator.isFilterValid(filterValue).should.equal isValid
