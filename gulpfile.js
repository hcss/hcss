'use strict';

var gulp = require('gulp');
var path = require('path');
var sass = require('gulp-sass');
var jade = require('gulp-jade');


var jadesassDir = './src/build',
  htmlcssDir = './src/build';
var source = {
  sassDir: path.join(jadesassDir, 'jade-sass/sass/**/*.sass'),
  jadeDir: path.join(jadesassDir, 'jade-sass/jade/**/*.jade')
}
var htmlcssOutput = {
  cssDir: path.join(htmlcssDir, 'html-css/css'),
  htmlDir: path.join(htmlcssDir, 'html-css/html')
}


gulp.task('sass', function () {
  gulp.src(source.sassDir)
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest(htmlcssOutput.cssDir));
});

gulp.task('jade', function() {
  gulp.src(source.jadeDir)
    .pipe(jade({
      pretty: true
    }))
    .pipe(gulp.dest(htmlcssOutput.htmlDir))
});


gulp.task('sass:watch', function () {
  gulp.watch(source.sassDir, ['sass']);
});

gulp.task('jade:watch', function () {
  gulp.watch(source.jadeDir, ['jade']);
});

gulp.task('build', ['sass', 'jade']);
gulp.task('watch', ['sass:watch', 'jade:watch']);

gulp.task('default', ['build', 'watch']);
