_ = require 'lodash'

updateWithElementA = (myElement, elementAList) ->
  currentElementA = _.find elementAList, (elementA) ->
    elementA.keyId is myElement.keyId
  myElement.min = currentElementA?.min
  myElement.max = currentElementA?.max
  myElement

updateWithElementB = (myElement, elementBList) ->
  currentElementB = _.find elementBList, (elementB) ->
    elementB.keyId is myElement.keyId
  myElement.team = currentElementB?.team
  myElement.department = currentElementB?.team?.department
  myElement.ssc = currentElementB?.team?.department?.ssc
  myElement

update = (myElement, elementAList, elementBList) ->
  myElement = updateWithElementA myElement, elementAList
  updateWithElementB myElement, elementBList

module.exports =
  update: update
