privateMethods = require '../../server/private-methods'
using = require '../common/utils/data-provider'

describe 'privateMethods', ->
  describe 'update', ->
    beforeEach ->
      @myElement =
        keyId: 42
        min: 10
        max: 11
        team: id: 1200
        department: id: 1300
        ssc: id: 1400

    describe 'updateWithElementA', ->
      elementADataProvider = [
        {list: null}
        {list: []}
        {
          list: [
            {id: 1, keyId: 11}
            {id: 2, keyId: 12}
            {id: 3, keyId: 13}
          ]
        }
        {
          list: [
            {id: 1, keyId: 41, min: 21, max: 31}
            {id: 2, keyId: 42, min: 22, max: 32}
            {id: 3, keyId: 43, min: 23, max: 33}
          ]
          expectedMin: 22
          expectedMax: 32
        }
      ]
      using elementADataProvider, (data) ->
        it 'should update thresholds with elementA', ->
          myElement = update @myEntity, data.list
          should.equal myElement.min, data.expectedMin
          should.equal myElement.max, data.expectedMax

    describe 'updateWithElementB', ->
      elementBDataProvider = [
        {list: null}
        {list: []}
        {
          list: [
            {id: 1, keyId: 11}
            {id: 2, keyId: 12}
            {id: 3, keyId: 13}
          ]
        }
        {
          list: [
            {id: 1, keyId: 41}
            {id: 2, keyId: 42}
            {id: 3, keyId: 43}
          ]
        }
        {
          list: [
            {id: 1, keyId: 41, team: id: 11}
            {id: 2, keyId: 42, team: id: 12}
            {id: 3, keyId: 43, team: id: 13}
          ]
          expectedTeam: id: 12
        }
        {
          list: [
            {id: 1, keyId: 41, team: id: 11, department: id: 21}
            {id: 2, keyId: 42, team: id: 12, department: id: 22}
            {id: 3, keyId: 43, team: id: 13, department: id: 23}
          ]
          expectedTeam: id: 12, department: id: 22
          expectedDepartment: id: 22
        }
        {
          list: [
            {id: 1, keyId: 41, team: id: 11, department: id: 21, ssc: id: 31}
            {id: 2, keyId: 42, team: id: 12, department: id: 22, ssc: id: 32}
            {id: 3, keyId: 43, team: id: 13, department: id: 23, ssc: id: 33}
          ]
          expectedTeam: id: 12, department: id: 22, ssc: id: 32
          expectedDepartment: id: 22, ssc: id: 32
          expectedSsc: id: 32
        }
      ]
      using elementBDataProvider, (data, index) ->
        it 'should update team, department, ssc with elementB', ->
          myElement = update @myEntity, null, data.list
          assert.deepEqual myElement.team, data.expectedTeam
          assert.deepEqual myElement.department, data.expectedDepartment
          assert.deepEqual myElement.ssc, data.expectedSsc
          myElement.should.equal sinon.match
            team: data.expectedTeam
            Department: data.expectedDepartment
            ssc: data.expectedSsc
