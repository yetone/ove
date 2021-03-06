require! {
    http
    './router': {Router}
    './context': {Context}
    \./utils
    \./logger
    \node-static
}

class Ove
    ->
        @config =
            cookie-expires: 30
            cookie-secure-token: \ove
        @g = {}
        @middlewares = []
        @router = new Router

        self = @
        for method in utils.method-list
            ((method) ->
                self[method.to-lower-case!] = (...args) ->
                    args.push([method])
                    self.register.apply self, args
            ) method

    config: (obj) ->
        @config <<< obj
        @

    register: (...args) ->
        @router.register.apply @router, args
        @

    use: (func) ->
        unless typeof! func is \Function
            return @register ...
        idx = @middlewares.length + 1
        self = @
        @middlewares.push (last) !->
            ctx = @
            func.call ctx, ->
                if self.middlewares[idx]
                    that.call ctx, last
                else
                    last.call ctx
        @

    static: (pattern, path, opt) ->
        @static-server = new node-static.Server path, opt
        pattern = if pattern.char-at(pattern.length - 1) is \/ then pattern else pattern + \/
        @static-re = new RegExp \^ + pattern.replace /\//g '\\/'
        self = @
        @use (next) !->
            if not @req.url.match self.static-re
                next!
            @req.url .= replace self.static-re, ''
            self.static-server.serve @req, @resp
        @

    register-status: (status-code, handler) ->
        if not @config.status-handler-map
            @config.status-handler-map = {}
        @config.status-handler-map[status-code] = handler
        @

    callback: ->
        self = @
        (req, resp) ->
            ctx = new Context req, resp, self.config, self.g
            self.config.charset and ctx.set-charset self.config.charset
            if self.middlewares[0]
                that.call ctx, -> self.router.route ctx
            else
                self.router.route ctx

    listen: (port, host) ->
        if not port
            port = 8888
        if not host
            host = '127.0.0.1'

        server = http.create-server @callback!

        do
            <- server.listen port, host
            logger.log "Ove app started.\n
                Listening %s:%d"
                , host, port

    run: ->
        @listen ...
        @

module.exports = ->
    new Ove ...
