require! <[ gulp gulp-livescript gulp-mocha ]>

gulp.task \test ->
    gulp.src \test/*.js {read: false}
        .pipe gulp-mocha {reporter: \nyan}

gulp.task \build ->
    gulp.src \src/*.ls
        .pipe gulp-livescript {bare: true}
        .on \error -> throw it
        .pipe gulp.dest \lib/

    gulp.src \test/*.ls
        .pipe gulp-livescript {bare: true}
        .on \error -> throw it
        .pipe gulp.dest \test/

    gulp.src \gulpfile.ls
        .pipe gulp-livescript {bare: true}
        .on \error -> throw it
        .pipe gulp.dest \.

gulp.task \default ->
    gulp.run \build
    gulp.watch [
        \src/*.ls
        \src/**/*.ls
        \test/*.ls
        \test/**/*.ls
        \gulpfile.ls
    ]
    , ->
        gulp.run \build
