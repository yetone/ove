require! {
    url
    \./logger
    \./utils
}

status-map = do
    404: 'Not found.'
    405: 'Method not allowed.'
    502: 'Server Error.'

class Context
    (req, resp, config) ->
        @req = req
        @resp = resp
        url-obj = url.parse req.url
        @url = req.url
        @search = url-obj.search
        @query = url-obj.query
        @pathname = url-obj.pathname
        @query-params = utils.query-str-to-obj url-obj.query
        @headers = req.headers
        @cookies = utils.parse-cookie req.headers.cookie
        @params = {}
        @form = {}
        @_resp-headers = {}
        @_resp-cookies = {}
        @_resp-charset = \UTF-8

    set-charset: (@_resp-charset) !->

    set-header: (key, value) !->
        obj = key
        if typeof! key is not \Object
            obj = {}
            obj[key] = value
        @_resp-headers <<< obj

    set-cookie: (key, value, opt) !->
        opt = do
            path: \/
            expires: 30
            domain: undefined
            http-only: true
            secure: false
            overwrite: false
        <<< opt
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
        if config.cookie-secure-token
            value = utils.encode-str that, value
        @set-cookie key, value, opt

    send: (...args) !->
        [statusCode, content] = args
        if not content
            [statusCode, content] = [200, statusCode]
        cookie-acc = []
        for _, item of @_resp-cookies
            cookie-acc.push item
        @_resp-headers <<< do
            'Set-Cookie': cookie-acc
        @resp.write-head statusCode, @_resp-headers
        @resp.end content

    json: (obj) !->
        @set-header \Content-Type, 'application/json; charset=' + @_resp-charset
        try
            str = JSON.stringify obj
        catch {message}
            error = 'response.json require a Object param can be stringified to string'
            logger.error error
            return
        @send str

    html: (str) !->
        @set-header \Content-Type, 'text/html; charset=' + @_resp-charset
        @send str

    send-status: (status-code) !->
        @send status-code, that if status-map[status-code]

exports.Context = Context
