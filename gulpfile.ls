require! <[ gulp gulp-livescript ]>

gulp.task \build ->
    gulp.src \./src/*.ls
        .pipe gulp-livescript {bare: true}
        .on \error -> throw it
        .pipe gulp.dest \./lib/

gulp.task \default ->
    gulp.run \build
    gulp.watch [\./src/*.ls, \./src/**/*.ls] ->
        gulp.run \build
