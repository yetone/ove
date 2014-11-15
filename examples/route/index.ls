ove = require '../..'
app = ove!

app.static \/public/ \./public

.use (next) ->
    console.log \md0 @url
    next!

.use (next) ->
    console.log \md1 @url
    next!

.register-status 404 ->
    @send 'ooooooooooooooh, noooooooooooooo!'

.get \/test/ ->
    @set-cookie \love \you
    console.log \cookies:, @cookies, \\n
    console.log \headers:, @headers, \\n
    console.log \ip:, @ip, \\n
    @set-secure-cookie \miss @query-params.miss || \home
    @send 'hello world'

.get \/user/:uid/ ->
    cookie = @get-secure-cookie \miss \nothing
    @send 'hello ' + @params.uid + ', miss ' + cookie

.get \/redirect/ ->
    @redirect \/user/yetone/

.post \/foo/:name/bar/:age/ ->
    console.log @body
    console.log @params
    @json @form

.listen!
