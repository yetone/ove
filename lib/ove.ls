require! {
    http
    \./router
    \./context
    \node-static
}

class Ove
    ->
        @config = {}
        @middlewares = []
        @server = http.create-server!
        @router = new router.Router

        for name in <[ register get post put delete patch ]>
            this[name] = @router[name]

    config: (@config) ->

    use: (func) ->
        if typeof! func is not \Function
            throw new Error 'ove.use() expect a Function argument'
        idx = @middlewares.length + 1
        self = @
        @middlewares.push (ctx, last) !->
            func ctx, ->
                if self.middlewares[idx]
                    that ctx, last
                else
                    last ctx

    static: (path, opt) ->
        @static-server = new node-static.Server path, opt
        path = if path.char-at(0) is \. then path.slice(1) else path
        path = if path.char-at(0) is \/ then path else \/ + path
        path = if path.char-at(path.length - 1) is \/ then path else path + \/
        @static-re = new RegExp \^ + path.replace /\//g '\\/'

    listen: (...args) ->
        [port, host] = args
        if not port
            port = 8888
        if not host
            host = '127.0.0.1'

        self = @

        do
            (req, resp) <- @server.on \request
            ctx = new context.Context req, resp
            self.config.charset and ctx.set-charset self.config.charset
            if self.middlewares[0]
                that ctx, -> self.router.route ctx, self.static-re, self.static-server
            else
                self.router.route ctx, self.static-re, self.static-server

        do
            <- @server.listen port, host
            console.log "Ove app started.\n
                Listening: %s:%d"
                , host, port

module.exports = Ove
