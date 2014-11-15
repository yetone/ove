ove = require '../..'
app = ove!

app.static \/public/ \./public

app.use (next) ->
    console.log \md0 @url
    next!

app.use (next) ->
    console.log \md1 @url
    next!

app.get \/test/ ->
    @set-cookie \love \you
    console.log \cookies:, @cookies, \\n
    console.log \headers:, @headers, \\n
    console.log \ip:, @ip, \\n
    @send 'hello world'

app.get \/user/:uid/ ->
    @send 'hello ' + @params.uid

app.get \/redirect/ ->
    @redirect \/user/yetone/

app.post \/foo/:name/bar/:age/ ->
    console.log @body
    console.log @params
    @json @form

app.listen!
