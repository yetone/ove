Ove = require '../..'
app = new Ove

app.get \/test/ ->
    @send 'hello world'

app.post \/foo/:name/bar/:age/ ->
    console.log @params
    @json @form

app.listen!
