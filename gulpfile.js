var gulp, gulpLivescript, gulpMocha;
gulp = require('gulp');
gulpLivescript = require('gulp-livescript');
gulpMocha = require('gulp-mocha');
gulp.task('test', function(){
  return gulp.src('test/*.js', {
    read: false
  }).pipe(gulpMocha({
    reporter: 'nyan'
  }));
});
gulp.task('build', function(){
  gulp.src('src/*.ls').pipe(gulpLivescript({
    bare: true
  })).on('error', function(it){
    throw it;
  }).pipe(gulp.dest('lib/'));
  gulp.src('test/*.ls').pipe(gulpLivescript({
    bare: true
  })).on('error', function(it){
    throw it;
  }).pipe(gulp.dest('test/'));
  return gulp.src('gulpfile.ls').pipe(gulpLivescript({
    bare: true
  })).on('error', function(it){
    throw it;
  }).pipe(gulp.dest('.'));
});
gulp.task('default', function(){
  gulp.run('build');
  return gulp.watch(['src/*.ls', 'src/**/*.ls', 'test/*.ls', 'test/**/*.ls', 'gulpfile.ls'], function(){
    return gulp.run('build');
  });
});