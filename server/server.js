var boot = require('loopback-boot');
var loopback = require('loopback');
var promisify = require('loopback-promisify');

var app = module.exports = loopback();

app.start = function() {
  app.listen(function() {
    app.emit('started');
    var baseUrl = app.get('url').replace(/\/$/, '');
    console.log('Web server listening at: %s', baseUrl);
    if (app.get('loopback-component-explorer')) {
      var explorerPath = app.get('loopback-component-explorer').mountPath;
      console.log('Browse your REST API at %s%s', baseUrl, explorerPath);
    }
  });
};

boot(app, __dirname, function(err) {
  if (err) {
    throw err;
  }

  promisify(app);

  if (require.main === module) {
    app.start();
  }
});
