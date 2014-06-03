'use strict'

gulp = require 'gulp'

# Load gulp plugins
$ = require('gulp-load-plugins')()

# Another modules
source = require 'vinyl-source-stream'
browserify = require 'browserify'
coffeeify = require 'coffeeify'
nib = require 'nib'

# Helpers
jade_helpers = require './src/helpers/jade_helpers'

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
    root: './build/'
    scripts:
      output_dir: './build/js/'
      output_file: 'main.js'
    styles: './build/css/'
    images: './build/img/'

gulp.task 'build', ->

  # Scripts
  params =
    entries: [paths.src.scripts]
    extensions: ['.coffee']
  browserify params
    .transform coffeeify
    .bundle()
    .pipe source(paths.dest.scripts.output_file)
    .pipe $.streamify($.uglify())
    .pipe gulp.dest(paths.dest.scripts.output_dir)

  # Styles
  gulp.src paths.src.styles
    .pipe $.stylus
      use: [nib()]
    .pipe $.csso()
    .pipe gulp.dest(paths.dest.styles)

  # Templates
  gulp.src paths.src.templates.compiled
    .pipe $.jade
      data: jade_helpers
    .pipe gulp.dest(paths.dest.root)

  # Images
  gulp.src paths.src.images
    .pipe $.imagemin()
    .pipe gulp.dest(paths.dest.images)
