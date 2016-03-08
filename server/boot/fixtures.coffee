companies = require '../../fixtures/data/companies'
tasks = require '../../fixtures/data/tasks'

module.exports = (app) ->
  dataSource = app.dataSources.db

  fixtures =
    Task: tasks
    Company: companies

  total = 0
  count = 0
  _.forOwn fixtures, (fixture, relation) ->
    total++
    dataSource.automigrate relation, (error) ->
      count++
      if error
        console.log "Error migrating #{relation}"
        console.log error
      else
        Relation = app.models[relation]
        total += fixture.length
        # Exits when the fixture is empty
        Relation.destroyAll (error) ->
          if error
            console.log "ERROR deleting #{relation}"
          if count >= total
            console.log 'DONE'
          _.forEach fixture, (row) ->
            Relation.create row, (error, record) ->
              count++
              if error
                console.log 'Error inserting row'
                console.log error
              if count >= total
                console.log 'DONE'
