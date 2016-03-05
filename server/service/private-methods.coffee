_ = require 'lodash'

updateWithElementA = ->
  currentElementA = _.find elementAList, (elementA) ->
    elementA.keyId is myElement.keyId
  myElement.max = currentElementA?.min
  myElement.min = currentElementA?.max
  myElement

updateWithElementB = ->
  currentElementB = _.find elementBList, (elementB) ->
    elementB.keyId is myElement.keyId
  myElement.team = currentElementB?.team
  myElement.department = currentElementB?.team?.department
  myElement.ssc = currentElementB?.team?.department?.ssc
  myElement

update = (myElement, elementAList, elementBList) ->
  myElement = updateWithElementA myElement, elementAList
  updateWithElementB myElement, elementBList
