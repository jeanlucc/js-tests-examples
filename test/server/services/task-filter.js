var taskFilter = require('../../../server/services/task-filter');

describe('taskFilter', function() {
  describe('filter', function() {
    it('should return an empty array if no parameters are given', function() {
      taskFilter.filter().should.deep.equal([]);
    });

    it('should return an empty array if no tasks are given', function() {
      taskFilter.filter(null, 'filter').should.deep.equal([]);
    });

    it('should return tasks if no filters are given', function() {
      taskFilter.filter(['task1', 'task2']).should.deep.equal(['task1', 'task2']);
      taskFilter.filter(['task1', 'task2'], null).should.deep.equal(['task1', 'task2']);
    });

    var getCategoriesDataProvider = function() {
      var tasks = [
        {id: 1},
        {id: 2,categories: 'category1'},
        {id: 3,categories: 'category2'},
        {id: 4,categories: 'category2, category1'},
        {id: 5,categories: 'category1, category3'}
      ];

      var tasksCategory1 = [
        {id: 2,categories: 'category1'},
        {id: 4,categories: 'category2, category1'},
        {id: 5,categories: 'category1, category3'}
      ];

      var tasksCategory1Category3 = [
        {id: 2,categories: 'category1'},
        {id: 4,categories: 'category2, category1'},
        {id: 5,categories: 'category1, category3'}
      ];

      var tasksCategory2Category3 = [
        {id: 3,categories: 'category2'},
        {id: 4,categories: 'category2, category1'},
        {id: 5,categories: 'category1, category3'}
      ];

      var testCases = [
        {filter: {toto: 'fake-filter'}, expectedTasks: tasks},
        {filter: {categories: []}, expectedTasks: tasks},
        {filter: {categories: ['category51']}, expectedTasks: []},
        {filter: {categories: ['category1']}, expectedTasks: tasksCategory1},
        {filter: {categories: ['category1', 'category3', 'category51']}, expectedTasks: tasksCategory1Category3},
        {filter: {categories: ['category2', 'category3']}, expectedTasks: tasksCategory2Category3}
      ];

      return _.map(testCases, function(testCase) {
        testCase.tasks = tasks;
        testCase.filterName = 'categories';
        return testCase;
      });
    };

    var getCreatorDataProvider = function() {
      var tasks = [
        {id: 1},
        {id: 2,creator: 'toto'},
        {id: 3,creator: 'Toto'},
        {id: 4,creator: 'titi'},
        {id: 5,creator: 'tata'},
        {id: 6,creator: 'toto'}
      ];

      var tasksOfCreator = [
        {id: 2,creator: 'toto'},
        {id: 3,creator: 'Toto'},
        {id: 6,creator: 'toto'}
      ];

      var testCases = [
        {filter: {toto: 'fake-filter'}, expectedTasks: tasks},
        {filter: {creator: ''}, expectedTasks: tasks},
        {filter: {creator: 'tutu'}, expectedTasks: []},
        {filter: {creator: 'TOTO'}, expectedTasks: tasksOfCreator}
      ];

      return _.map(testCases, function(testCase) {
        testCase.tasks = tasks;
        testCase.filterName = 'creator';
        return testCase;
      });
    };

    var getNotFinishedOnlyDataProvider = function() {
      var tasks = [
        {status: 'DONE'},
        {status: 'TODO'},
        {status: 'IN_PROGRESS'}
      ];

      var filteredTasks = [
        {status: 'TODO'},
        {status: 'IN_PROGRESS'}
      ];

      var testCases = [
        {filter: {toto: 'fakeFilter'}, expectedTasks: tasks},
        {filter: {notFinishedOnly: false}, expectedTasks: tasks},
        {filter: {notFinishedOnly: true}, expectedTasks: filteredTasks},
        {filter: {notFinishedOnly: ''}, expectedTasks: tasks},
        {filter: {notFinishedOnly: 0}, expectedTasks: tasks},
        {filter: {notFinishedOnly: []}, expectedTasks: tasks}
      ];

      return _.map(testCases, function(testCase) {
        testCase.tasks = tasks;
        testCase.filterName = 'not finished only';
        return testCase;
      });
    };

    var getGlobalDataProvider = function() {
      return [
        {
          tasks: [
            {
              id: 1,
              status: 'TODO',
              creator: 'Bobby',
              categories: 'category1, category2, category51'
            }, {
              id: 2,
              status: 'DONE',
              creator: 'Bobby',
              categories: 'category2, category51'
            }, {
              id: 3,
              status: 'TODO',
              creator: 'Bobby',
              categories: 'category1, category2'
            }, {
              id: 4,
              status: 'TODO',
              creator: 'creator1',
              categories: 'category1, category51'
            }
          ],
          expectedTasks: [
            {
              id: 1,
              status: 'TODO',
              creator: 'Bobby',
              categories: 'category1, category2, category51'
            }
          ],
          filter: {
            categories: ['category51'],
            creator: 'Bobby',
            notFinishedOnly: true
          },
          filterName: 'all filters'
        }
      ];
    };

    var filterDataProvider = [].concat(
      getCategoriesDataProvider(),
      getCreatorDataProvider(),
      getNotFinishedOnlyDataProvider(),
      getGlobalDataProvider()
    );
    using(filterDataProvider, function(args) {
      it('should return tasks filtered by ' + args.filterName, function() {
        taskFilter.filter(args.tasks, args.filter).should.deep.equal(args.expectedTasks);
      });
    });
  });
});
