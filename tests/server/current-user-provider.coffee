assert = require('chai').assert
currentUserProvider = require '../../server/service/current-user-provider'
loopback = require 'loopback'
sinon = require 'sinon'
using = require '../common/utils/data-provider'

describe 'currentUserProvider', ->
  describe 'find', ->
    currentUserDataProvider = [
      {context: undefined, expectedResult: null}
      {context: get: undefined, expectedResult: null}
      {context: get: 'toto', expectedResult: null}
      {context: get: name: 'toto', expectedResult: null}
      {context: get: -> undefined, expectedResult: null}
      {context: get: -> id: 42, expectedResult: id: 42}
    ]
    using currentUserDataProvider, (data) ->
      it 'should return the current user or null', ->
        sinon.stub(loopback, 'getCurrentContext').returns data.context
        assert.deepEqual currentUserProvider.find(), data.expectedResult
