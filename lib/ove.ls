require! {
    http
    \./router
}
Context = require \./context

class Ove
    ->
        @server = http.create-server!
        @router = new router.Router

        for name in <[ register get post put delete patch ]>
            this[name] = @router[name]

    listen: (...args) ->
        [port, host] = args
        if not host
            host = '127.0.0.1'

        do
            (req, resp) <- @server.on \request
            ctx = new Context req, resp
            @router.route ctx

        do
            <- @server.listen port, host
            console.log "Ove app started.\n
                Listening: %s:%d"
                , host, port

module.exports = Ove
