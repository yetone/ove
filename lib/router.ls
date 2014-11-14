_ = require 'prelude-ls'
require! {
    url
}

get-pattern-list = ->
    # TODO
    []

class Router
    ->
        @method-list = [\GET \POST \PUT \DELETE \PATCH]
        @handler-list = []

        for name in @method-list
            ((name) ->
                this[name.to-lower-case!] = !->
                    @register(pattern, handler, name)
            ) name

    register: (pattern, handler, method-list) !->
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
                        method <- item.method-list.map
                        method.to-upper-case!
                | \String =>
                    method-list = [method-list.to-upper-case!]
                | _ =>
                    method-list = [\GET]

            @handler-list.push [
                pattern
                handler
                method-list
            ]

    route: (ctx) !->
        self = @
        if ctx.req.method is \POST
            body = ''
            do
                data <- ctx.req.on \data
                body += data
        param-re = //:[^\/]+//g
        pathname = url.parse ctx.req.url .pathname
        pathname = if pathname.char-at(pathname.length - 1) is \/ then pathname else pathname + \/
        matched = false
        for item in @handler-list
            [pattern, handler, method-list] = item
            if pattern.replace //[\/\w:\*]//g ''
                throw new Error 'The router pattern is error: ' + pattern
            param-names = pattern.match param-re .map ->
                it.slice(1)
            pattern = \^ + pattern + '$'
            pattern = pattern.replace //\///g '\\/'
                            .replace //\*//g '[^\\/]*'
                            .replace //\*\*//g '.*'
                            .replace param-re, '([^\\/]+)'
            re = new RegExp pattern
            m-arr = pathname.match re
            if not m-arr
                continue
            matched = true
            if ctx.req.method not in method-list
                continue
            for name, idx in param-names
                ctx.params[name] = m-arr[idx]
            if ctx.req.method is \POST
                do
                    <- ctx.req.on \end
                    ctx.form = utils.query-str-to-obj body
                    handler.call ctx
                return
            handler.call ctx
            return
        if matched
            ctx.send-status 405
