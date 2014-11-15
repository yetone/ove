_ = require 'prelude-ls'
require! {
    url
    \./utils
}

get-pattern-list = ->
    # TODO
    []

class Router
    ->
        @method-list = <[ GET POST PUT DELETE PATCH HEAD OPTIONS ]>
        @handler-list = []

        self = @

        for name in @method-list
            ((name) ->
                self[name.to-lower-case!] = (...args) ->
                    args.push([name.to-upper-case!])
                    self.register.apply self, args
                    @
            ) name

    register: (pattern, handler, method-list) ->
        arr = []
        switch typeof! pattern
            | \Array => arr = pattern
            | \Object => arr = get-pattern-list pattern
            | _ =>
                arr.push [
                    pattern
                    handler
                    method-list
                ]

        for item in arr
            [pattern, handler, method-list] = item
            switch typeof! method-list
                | \Array =>
                    method-list = do
                        method <- method-list.map
                        method.to-upper-case!
                | \String =>
                    method-list = [method-list.to-upper-case!]
                | _ =>
                    method-list = [\GET]

            param-re = /:[^\/]+/g
            if pattern.replace /[\/\w:\*]/g ''
                throw new Error 'The router pattern is error: ' + pattern
            param-names = if pattern.match param-re then that.map -> it.slice(1) else []
            pattern = if pattern.char-at(pattern.length - 1) is \/ then pattern else pattern + \/
            pattern = \^ + pattern + \$
            pattern .= replace param-re, '([^\/]+)'
                .replace /\*/g '[^\\/]*'
                .replace /\*\*/g '.*'
                .replace /\//g '\\/'

            pattern = new RegExp pattern

            @handler-list.push [
                pattern
                handler
                method-list
                param-names
            ]
            @

    route: (ctx) !->
        self = @
        if ctx.req.method is \POST
            ctx.body = ''
            do
                data <- ctx.req.on \data
                ctx.body += data
        pathname = url.parse ctx.req.url .pathname
        pathname = if pathname.char-at(pathname.length - 1) is \/ then pathname else pathname + \/

        matched = false
        for item in @handler-list
            [pattern, handler, method-list, param-names] = item
            m-arr = pathname.match pattern
            if not m-arr
                continue
            matched = true
            if ctx.req.method not in method-list
                continue
            for name, idx in param-names
                ctx.params[name] = m-arr[++idx]
            if ctx.req.method is \POST
                do
                    <- ctx.req.on \end
                    ctx.form = utils.query-str-to-obj ctx.body
                    handler.call ctx
                return
            handler.call ctx
            return
        if matched
            ctx.send-status 405
        else
            ctx.send-status 404

exports.Router = Router
