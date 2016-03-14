_ = require 'lodash'
moment = require 'moment'
should = require('chai').should()
sinon = require 'sinon'
taskSanitizer = require '../../../server/services/task-sanitizer'

describe 'taskSanitizer', ->
  describe 'sanitize', ->
    it 'should update information and delete immutable fields for edition', ->
      taskSanitizer.sanitize id: 42, createDate: '13-11-1128', updateDate: '27-08-1982'
      .should.satisfy (task) ->
        now = moment()
        updateDateDifference = now.diff moment task.updateDate
        _.keys(task).should.deep.equal ['id', 'updateDate']
        updateDateDifference.should.be.below 50
        task.id.should.equal 42

    it 'should add information for creation', ->
      taskSanitizer.sanitize content: 'something to do'
      .should.satisfy (task) ->
        now = moment()
        updateDateDifference = now.diff moment task.updateDate
        createDateDifference = now.diff moment task.createDate
        updateDateDifference.should.be.below 50
        createDateDifference.should.be.below 50
