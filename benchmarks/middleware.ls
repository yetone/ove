ove = require \..
app = ove!

n = parse-int process.env.MW || '1', 10
console.log ' %s middleware' n

while n--
    app.use (next) ->
        next!

body = new Buffer 'Hello ove'

app.use (next) ->
    next!
    @body = body

app.listen 3456
