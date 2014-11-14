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
    (req, resp) ->
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
        @_resp-charset = \UTF-8

    set-charset: (@_resp-charset) !->

    set-header: (key, value) !->
        obj = {}
        if typeof! key is not \Object
            obj[key] = value
        else
            obj = key
        @_resp-headers <<< obj

    send: (...args) !->
        [statusCode, content] = args
        if not content
            [statusCode, content] = [200, statusCode]
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
