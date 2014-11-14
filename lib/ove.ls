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

    static: (pattern, path, opt) ->
        @static-server = new node-static.Server path, opt
        pattern = if pattern.char-at(pattern.length - 1) is \/ then pattern else pattern + \/
        @static-re = new RegExp \^ + pattern.replace /\//g '\\/'
        self = @
        @use (ctx, next) !->
            if not ctx.req.url.match self.static-re
                next!
            ctx.req.url .= replace self.static-re, ''
            self.static-server.serve ctx.req, ctx.resp

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
                that ctx, -> self.router.route ctx
            else
                self.router.route ctx

        do
            <- @server.listen port, host
            console.log "Ove app started.\n
                Listening: %s:%d"
                , host, port

module.exports = Ove
