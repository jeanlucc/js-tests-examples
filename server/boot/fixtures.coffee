_ = require 'lodash'
companies = require '../../fixtures/data/companies'
departments = require '../../fixtures/data/departments'
managers = require '../../fixtures/data/managers'
tasks = require '../../fixtures/data/tasks'
teams = require '../../fixtures/data/teams'

module.exports = (app) ->
  dataSource = app.dataSources.db

  fixtures =
    Task: tasks
    Company: companies
    Department: departments
    Team: teams
    Manager: managers

  total = 0
  count = 0
  _.forOwn fixtures, (fixture, relation) ->
    total++
    dataSource.automigrate relation, (error) ->
      count++
      console.log "Error migrating #{relation}", error if error
      Relation = app.models[relation]
      total += fixture.length
      Relation.destroyAll (error) ->
        console.log "ERROR deleting #{relation}", error if error
        console.log 'DONE' if count >= total
        _.forEach fixture, (row) ->
          Relation.create row, (error, record) ->
            count++
            console.log 'Error inserting row', error if error
            console.log 'DONE' if count >= total
