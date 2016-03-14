_ = require 'lodash'
should = require('chai').should()
sinon = require 'sinon'
taskFilter = require '../../../server/services/task-filter'
using = require '../../common/utils/data-provider'

describe 'taskFilter', ->
  describe 'filter', ->
    it 'should return an empty array if no parameters are given', ->
      taskFilter.filter().should.deep.equal []

    it 'should return an empty array if no tasks are given', ->
      taskFilter.filter(null, 'filter').should.deep.equal []

    it 'should return tasks if no filters are given', ->
      taskFilter.filter(['task1', 'task2']).should.deep.equal ['task1', 'task2']
      taskFilter.filter(['task1', 'task2'], null).should.deep.equal ['task1', 'task2']

    getCategoriesDataProvider = ->
      tasks = [
        {id:1}
        {id:2, categories: 'category1'}
        {id:3, categories: 'category2'}
        {id:4, categories: 'category2, category1'}
        {id:5, categories: 'category1, category3'}
      ]
      tasksCategory1 = [
        {id:2, categories: 'category1'}
        {id:4, categories: 'category2, category1'}
        {id:5, categories: 'category1, category3'}
      ]
      tasksCategory1Category3 = [
        {id:2, categories: 'category1'}
        {id:4, categories: 'category2, category1'}
        {id:5, categories: 'category1, category3'}
      ]
      tasksCategory2Category3 = [
        {id:3, categories: 'category2'}
        {id:4, categories: 'category2, category1'}
        {id:5, categories: 'category1, category3'}
      ]
      _.map [
        filter: toto: 'fake-filter'
        expectedTasks: tasks
      ,
        filter: categories: []
        expectedTasks: tasks
      ,
        filter: categories: ['category51']
        expectedTasks: []
      ,
        filter: categories: ['category1']
        expectedTasks: tasksCategory1
      ,
        filter: categories: ['category1', 'category3', 'category51']
        expectedTasks: tasksCategory1Category3
      ,
        filter: categories: ['category2', 'category3']
        expectedTasks: tasksCategory2Category3
      ] , (testCase) ->
        testCase.tasks = tasks
        testCase.filterName = 'categories'
        testCase

    getCreatorDataProvider = ->
      tasks = [
        {id:1}
        {id:2, creator: 'toto'}
        {id:3, creator: 'Toto'}
        {id:4, creator: 'titi'}
        {id:5, creator: 'tata'}
        {id:6, creator: 'toto'}
      ]
      tasksOfCreator = [
        {id:2, creator: 'toto'}
        {id:3, creator: 'Toto'}
        {id:6, creator: 'toto'}
      ]
      _.map [
        filter: toto: 'fake-filter'
        expectedTasks: tasks
      ,
        filter: creator: ''
        expectedTasks: tasks
      ,
        filter: creator: 'tutu'
        expectedTasks: []
      ,
        filter: creator: 'TOTO'
        expectedTasks: tasksOfCreator
      ] , (testCase) ->
        testCase.tasks = tasks
        testCase.filterName = 'creator'
        testCase

    getNotFinishedOnlyDataProvider = ->
      tasks = [
        {status: 'DONE'}
        {status: 'TODO'}
        {status: 'IN_PROGRESS'}
      ]
      filteredTasks = [
        {status: 'TODO'}
        {status: 'IN_PROGRESS'}
      ]
      _.map [
        filter: toto: 'fakeFilter'
        expectedTasks: tasks
      ,
        filter: notFinishedOnly: false
        expectedTasks: tasks
      ,
        filter: notFinishedOnly: true
        expectedTasks: filteredTasks
      ,
        filter: notFinishedOnly: ''
        expectedTasks: tasks
      ,
        filter: notFinishedOnly: 0
        expectedTasks: tasks
      ,
        filter: notFinishedOnly: []
        expectedTasks: tasks
      ], (testCase) ->
        testCase.tasks = tasks
        testCase.filterName = 'not finished only'
        testCase

    getGlobalDataProvider = -> [
      tasks: [
        id: 1
        status: 'TODO'
        creator: 'Bobby'
        categories: 'category1, category2, category51'
      ,
        id: 2
        status: 'DONE'
        creator: 'Bobby'
        categories: 'category2, category51'
      ,
        id: 3
        status: 'TODO'
        creator: 'Bobby'
        categories: 'category1, category2'
      ,
        id: 4
        status: 'TODO'
        creator: 'creator1'
        categories: 'category1, category51'
      ]
      expectedTasks: [
        id: 1
        status: 'TODO'
        creator: 'Bobby'
        categories: 'category1, category2, category51'
      ]
      filter:
        categories: ['category51']
        creator: 'Bobby'
        notFinishedOnly: true
      filterName: 'all filters'
    ]

    filterDataProvider = [].concat getCategoriesDataProvider(),
      getCreatorDataProvider(),
      getNotFinishedOnlyDataProvider(),
      getGlobalDataProvider()
    using filterDataProvider, ({tasks, expectedTasks, filter, filterName}) ->
      it "should return tasks filtered by #{filterName}", ->
        filteredTask = taskFilter.filter tasks, filter
        filteredTask.should.deep.equal expectedTasks
