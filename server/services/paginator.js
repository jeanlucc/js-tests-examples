getPage = function(dataList, page, pageLength) {
    var begin = (page - 1) * pageLength;
    var end = begin + pageLength;
    return dataList.slice(begin, end);
}

module.exports = {
    getPage: getPage
}
