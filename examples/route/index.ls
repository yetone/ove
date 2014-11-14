Ove = require '../..'
app = new Ove

app.static \/public/ \./public

app.use (ctx, next) ->
    console.log \md0
    next!

app.use (ctx, next) ->
    console.log \md1
    next!

app.get \/test/ ->
    @send 'hello world'

app.post \/foo/:name/bar/:age/ ->
    console.log @params
    @json @form

app.listen!
