gulp = require 'gulp'
mocha = require 'gulp-mocha'
istanbul = require 'gulp-coffee-istanbul'

gulp.task 'coverage', ->
  gulp.src [
    '../common/**/*.coffee'
    '../server/**/*.coffee'
  ]
  .pipe istanbul includeUntested: false
  .pipe istanbul.hookRequire()
  .on 'finish', ->
    gulp.src [
      './config.coffee'
      './common/**/*.coffee'
      './server/**/*.coffee'
    ]
    .pipe mocha()
    .pipe istanbul.writeReports
      reporters: ['lcov', 'json']
      dir: '../coverage/server-report'
    .once 'error', -> process.exit()
    .once 'end', -> process.exit()
