gulp = require 'gulp'
cache = require 'gulp-cached'
remember = require 'gulp-remember'
source = require 'vinyl-source-stream'
browserify = require 'browserify'
coffeeify = require 'coffeeify'
livereload = require 'gulp-livereload'
notify = require 'gulp-notify'
stylus = require 'gulp-stylus'
nib = require 'nib'
jade = require 'gulp-jade'
imagemin = require 'gulp-imagemin'
connect = require 'connect'
connect_lr = require 'connect-livereload'

paths =
  src:
    root: './src/'
    scripts: './src/js/main.coffee'
    styles: './src/css/main.styl'
    images: './src/img/**/*'
    templates: 
      all: './src/tpl/**/*'
      compiled: ['./src/tpl/*.jade', '!./src/tpl/_*.jade']
  dest: 
    root: './public/'
    scripts:
      output_dir: './public/js/'
      output_file: 'main.js'
    styles: './public/css/'
    images: './public/img/'
  build:
    root: './build/'
    scripts:
      output_dir: './build/js/'
      output_file: 'main.js'
    styles: './build/css/'
    images: './build/img/'

handleErrors = ->
  args = Array::slice.call arguments
  notify.onError(
    title: 'Compile error'
    message: '<%= error.message %>'
  ).apply this, args
  @emit 'end'


# Scripts
gulp.task 'browserify', ->
  params =
    entries: [paths.src.scripts]
    extensions: ['.coffee']

  browserify params
    .transform coffeeify # CoffeeScript compile
    .bundle { debug: true } # Bundle to source stream
    .on 'error', handleErrors # Catch errors
    .pipe cache('browserified')
    .pipe source(paths.dest.scripts.output_file) # Output filename
    .pipe gulp.dest(paths.dest.scripts.output_dir) # Piping stream to task
    .pipe remember('browserified')
    .pipe livereload()


# Styles
gulp.task 'stylus', ->
  gulp.src paths.src.styles
    .pipe stylus
      use: [nib()]
    .on 'error', handleErrors
    .pipe cache('stylused')
    .pipe gulp.dest(paths.dest.styles)
    .pipe remember('stylused')
    .pipe livereload()


# Templates
gulp.task 'jade', ->
  gulp.src paths.src.templates.compiled
    .pipe jade
      pretty: true
    .on 'error', handleErrors
    .pipe cache('jaded')
    .pipe gulp.dest(paths.dest.root)
    .pipe remember('jaded')
    .pipe livereload()


# Images
gulp.task 'images', ->
  gulp.src paths.src.images
    .pipe imagemin()
    .pipe gulp.dest(paths.dest.images)


# Web server
gulp.task 'server', ->
  connect()
    .use connect_lr()
    .use connect.static(paths.dest.root)
    .listen 9000
  console.log 'Server listening on http://localhost:9000'


# Watch tasks
gulp.task 'watch', ->
  gulp.watch paths.src.scripts, ['browserify']
  gulp.watch paths.src.styles, ['stylus']
  gulp.watch paths.src.templates.all, ['jade']
  gulp.watch paths.src.images, ['images']

gulp.task 'default', ['stylus', 'jade', 'images', 'watch', 'server']

require './GuilpfileProd'