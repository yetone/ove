Ove = require '../..'
app = new Ove

app.static \/public/ \./public

app.use (next) ->
    console.log \md0 @url
    next!

app.use (next) ->
    console.log \md1 @url
    next!

app.get \/test/ ->
    @set-cookie \love \you
    console.log @cookies
    @send 'hello world'

app.post \/foo/:name/bar/:age/ ->
    console.log @params
    @json @form

app.listen!
