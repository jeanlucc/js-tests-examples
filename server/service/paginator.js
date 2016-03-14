getPage = function(dataList, page, pageLength) {
    var begin = (page - 1) * pageLength;
    var end = begin + pageLength;
    dataList.slice(begin, end);

    return dataList;
}

module.exports = {
    getPage: getPage
}
