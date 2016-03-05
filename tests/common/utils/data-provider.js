// https://github.com/jphpsf/jasmine-data-provider/blob/master/spec/SpecHelper.js
function using(values, func){
  for (var i = 0, count = values.length; i < count; i++) {
    if (Object.prototype.toString.call(values[i]) !== '[object Array]') {
      values[i] = [values[i], i];
    }
    func.apply(this, values[i]);
  }
}

module.exports = using;
