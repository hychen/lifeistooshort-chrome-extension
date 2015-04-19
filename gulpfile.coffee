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

baseDir = './app'
preparation = [
  './app/js/libs/**/*'
  './app/css/vendor/**/*'
  './app/manifest.json'
]

gulp.task 'jade', ->
  gulp.src './app/jade/**/*.jade'
    .pipe jade()
    .pipe plumber()
    .pipe gulp.dest('./build/')
    .pipe notify('jade: <%= file.relative %>')

gulp.task 'coffee', ->
  gulp.src './app/coffee/**/*.coffee'
    .pipe plumber()
    .pipe coffee()
    .pipe gulp.dest('./build/js/')
    .pipe notify('coffee: <%= file.relative %>')

gulp.task 'prepare', ->
  shell.rm('-rf', ['build', 'dist'])
  gulp.src preparation, {base: './app'}
    .pipe gulp.dest('./build/')

gulp.task 'sass', ->
  gulp.src './app/sass/**/*.sass'
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
