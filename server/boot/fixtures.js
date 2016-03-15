var _ = require('lodash');
var companies = require('../../fixtures/data/companies');
var departments = require('../../fixtures/data/departments');
var managers = require('../../fixtures/data/managers');
var tasks = require('../../fixtures/data/tasks');
var teams = require('../../fixtures/data/teams');

module.exports = function(app) {
  var dataSource = app.dataSources.db

  var fixtures =
    Task: tasks
    Company: companies
    Department: departments
    Team: teams
    Manager: managers

  var total = 0
  var count = 0
  _.forOwn(fixtures, function(fixture, relation) {
    total++;
    dataSource.automigrate(relation, function(error) {
      count++;
      if (error) {
        console.log("Error migrating " + relation, error);
      }
      Relation = app.models[relation];
      total += fixture.length;
      Relation.destroyAll(function(error) {
        if (error) {
          console.log("ERROR deleting " + relation, error);
        }
        if (count >= total) {
          console.log('DONE');
        }
        _.forEach(fixture, function(row) {
          Relation.create(row, function(error, record) {
            count++;
            if (error) {
              console.log('Error inserting row', error);
            }
            if (count >= total) {
              return console.log('DONE');
            }
          });
        });
      });
    });
  });
}
