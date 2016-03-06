gulp = require 'gulp'
mocha = require 'gulp-mocha'
istanbul = require 'gulp-coffee-istanbul'

gulp.task 'coverage', ->
  gulp.src [
    '../server/**/*.coffee'
    '../common/**/*.coffee'
  ]
  .pipe istanbul includeUntested: false
  .pipe istanbul.hookRequire()
  .on 'finish', ->
    gulp.src [
      './server/**/*.coffee'
    ]
    .pipe mocha()
    .pipe istanbul.writeReports
      reporters: ['lcov', 'json']
      dir: '../coverage/server-report'
    .once 'error', -> process.exit()
    .once 'end', -> process.exit()
