assert = require('chai').assert
currentUserProvider = require '../../server/service/current-user-provider'
loopback = require 'loopback'
sinon = require 'sinon'
using = require '../common/utils/data-provider'

describe 'currentUserProvider', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create()

  afterEach ->
    @sandbox.restore()

  describe 'find', ->
    currentUserDataProvider = [
      {}
      {context: get: undefined}
      {context: get: 'toto'}
      {context: get: name: 'toto'}
      {context: get: -> undefined}
      {context: {get: -> id: 42}, expectedResult: id: 42}
    ]
    using currentUserDataProvider, (data) ->
      it 'should return the current user or null', ->
        @sandbox.stub(loopback, 'getCurrentContext').returns data.context
        assert.deepEqual currentUserProvider.find(), data.expectedResult
