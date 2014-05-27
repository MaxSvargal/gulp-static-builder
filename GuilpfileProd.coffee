gulp = require 'gulp'
source = require 'vinyl-source-stream'
browserify = require 'browserify'
coffeeify = require 'coffeeify'
stylus = require 'gulp-stylus'
nib = require 'nib'
jade = require 'gulp-jade'
imagemin = require 'gulp-imagemin'
csso = require 'gulp-csso'
uglify = require 'gulp-uglify'
streamify = require 'gulp-streamify'

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
    .pipe streamify(uglify())
    .pipe gulp.dest(paths.dest.scripts.output_dir)

  # Styles
  gulp.src paths.src.styles
    .pipe stylus
      use: [nib()]
    .pipe csso()
    .pipe gulp.dest(paths.dest.styles)

  # Templates
  gulp.src paths.src.templates.compiled
    .pipe jade()
    .pipe gulp.dest(paths.dest.root)

  # Images
  gulp.src paths.src.images
    .pipe imagemin()
    .pipe gulp.dest(paths.dest.images)
