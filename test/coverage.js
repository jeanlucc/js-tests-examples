var gulp = require('gulp');
var mocha = require('gulp-mocha');
var istanbul = require('gulp-istanbul');

gulp.task('coverage', function() {
  return gulp.src([
    '../server/**/*.js',
    '../common/models/*.js'
  ])
  .pipe(istanbul({includeUntested: false}))
  .pipe(istanbul.hookRequire())
  .on('finish', function() {
    gulp.src([
      './common/utils/config.js',
      './server/services/*.js',
      './common/models/*.js'
    ])
    .pipe(mocha())
    .pipe(istanbul.writeReports({
      reporters: ['lcov', 'json'],
      dir: '../coverage/server-report'
    }));
  });
});
