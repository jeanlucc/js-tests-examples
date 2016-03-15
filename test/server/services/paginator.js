require('../../common/utils/config');
// TODO in article require should directly
var paginator = require('../../../server/services/paginator');

describe('getPage', function(){
  it('should return the second page', function(){
    var dataList = ['item1', 'item2', 'item3', 'item4', 'item5', 'item6'];
    var page = paginator.getPage(dataList, 2, 2);
    page.should.deep.equal(['item3', 'item4']);
  })
})
