'use strict'

gulp = require 'gulp'
del = require 'del'
notify = require 'gulp-notify'
zip = require 'gulp-zip'

# Clean
gulp.task 'clean', ->
  del ['dist']

gulp.task 'pack', ->
  manifest = require './app/manifest'
  fn = "#{manifest.name}.v#{manifest.version}.zip"
  gulp.src 'app/**'
    .pipe zip fn
    .pipe gulp.dest 'dist'

gulp.task 'release', ['clean', 'pack']

