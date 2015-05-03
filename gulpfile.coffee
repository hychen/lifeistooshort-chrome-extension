'use strict'

gulp = require 'gulp'
del = require 'del'
notify = require 'gulp-notify'
zip = require 'gulp-zip'
sass = require 'gulp-sass'
coffee = require 'gulp-coffee'
jade = require 'gulp-jade'
plumber = require 'gulp-plumber'
runSeq = require 'run-sequence'
shell = require 'shelljs'
changed = require 'gulp-changed'

baseDir = './app'
preparation = [
  './app/js/libs/**/*'
  './app/css/vendor/**/*'
  './app/manifest.json'
]

gulp.task 'jade', ->
  gulp.src './app/jade/**/*.jade'
    .pipe changed('./build')
    .pipe plumber()
    .pipe jade()
    .pipe gulp.dest('./build/')
    .pipe notify('jade: <%= file.relative %>')

gulp.task 'coffee', ->
  gulp.src './app/coffee/**/*.coffee'
    .pipe changed('./build')
    .pipe plumber()
    .pipe coffee()
    .pipe gulp.dest('./build/js/')
    .pipe notify('coffee: <%= file.relative %>')

gulp.task 'prepare', ->
  shell.rm('-rf', ['build', 'dist'])
  gulp.src preparation, {base: './app'}
    .pipe gulp.dest('./build/')
    .pipe notify('preparation: <%= file.relative %>')

gulp.task 'sass', ->
  gulp.src './app/sass/**/*.sass'
    .pipe changed('./build')
    .pipe plumber()
    .pipe sass
      errLogToConsole: true
    .pipe gulp.dest('./build/css/')
    .pipe notify('sass: <%= file.relative %>')

gulp.task 'build', ['jade', 'coffee', 'sass']

gulp.task 'pack', ->
  manifest = require './app/manifest'
  fn = "#{manifest.name}.v#{manifest.version}.zip"
  gulp.src 'build/**'
    .pipe zip fn
    .pipe gulp.dest 'dist'

gulp.task 'watch', ->
  gulp.watch preparation, ['prepare']
  gulp.watch './app/coffee/**/*.coffee', ['coffee']
  gulp.watch './app/sass/**/*.sass', ['sass']
  gulp.watch './app/jade/**/*.jade', ['jade']

gulp.task 'release', ->
  runSeq(
    'prepare',
    'build',
    'pack'
  )

gulp.task 'dev', ->
  runSeq(
    'prepare',
    ['build', 'watch']
  )
