require! {
    \./logger
    \./utils
}

status-map = do
    404: 'Not found.'
    405: 'Method not allowed.'
    502: 'Server Error.'

exports.Response = do
    set-charset: (@_resp-charset) !->

    set-header: (key, value) !->
        obj = key
        if typeof! key is not \Object
            obj = {}
            obj[key] = value
        @_resp-headers <<< obj

    set-cookie: (key, value, opt) !->
        dft = do
            path: \/
            expires: @config.cookie-expires
            domain: undefined
            http-only: true
            secure: false
            overwrite: false
        switch typeof! opt
            | \Number =>
                opt = dft <<< do
                    expires: opt
            | \Object =>
                opt = dft <<< opt
            | _ =>
                opt = dft

        header = key + '=' + value
        if opt.path
            header += '; path=' + opt.path
        if opt.expires
            ex-date = new Date
            ex-date.set-date ex-date.get-date! + opt.expires
            header += '; expires=' + ex-date.to-UTC-string!
        if opt.domain
            header += '; domain' + opt.domain
        if opt.secure
            header += '; secure'
        if opt.http-only
            header += '; httponly'
        @_resp-cookies[key] = header

    set-secure-cookie: (key, value, opt) !->
        expires = @config.cookie-expires
        switch typeof! opt
            | \Number =>
                expires = opt
            | \Object =>
                expires = opt.expires or expires
        value = [value.length, utils.base64.encode(value), Date.now! + expires * 60 * 60 * 24]
        signature = utils.hex-hmac-sha1 (value.join \|), @config.cookie-secure-token

        value.push signature
        value .= join \| .replace /\=/g \*

        @set-cookie key, value, opt

    send: (status-code, content) !->
        unless typeof! status-code is \Number
            [status-code, content] = [200, status-code]
        cookie-acc = []
        for _, item of @_resp-cookies
            cookie-acc.push item
        @_resp-headers <<< do
            'Set-Cookie': cookie-acc
        @resp.write-head status-code, @_resp-headers
        @resp.end content

    json: (status-code, obj) !->
        unless typeof! status-code is \Number
            [status-code, obj] = [200, status-code]
        @set-header \Content-Type, 'application/json; charset=' + @_resp-charset
        try
            str = JSON.stringify obj
        catch {message}
            error = 'response.json require a Object param can be stringified to string'
            logger.error error
            return
        @send status-code, str

    html: (status-code, str) !->
        unless typeof! status-code is \Number
            [status-code, str] = [200, status-code]
        @set-header \Content-Type, 'text/html; charset=' + @_resp-charset
        @send status-code, str

    redirect: (url) !->
        @set-header \Location url
        @send 302

    send-status: (status-code) !->
        if @config.status-handler-map?[status-code]
            that.call @
            return
        @send status-code, that if status-map[status-code]
