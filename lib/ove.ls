require! {
    http
    \./router
    \./context
}

class Ove
    ->
        @server = http.create-server!
        @router = new router

        for name in <[ register get post put delete patch ]>
            this[name] = @router[name]

    listen: (...args) ->
        [port, host] = args
        if not port
            port = 8888
        if not host
            host = '127.0.0.1'

        self = @

        do
            (req, resp) <- @server.on \request
            ctx = new context req, resp
            self.router.route ctx

        do
            <- @server.listen port, host
            console.log "Ove app started.\n
                Listening: %s:%d"
                , host, port

module.exports = Ove
