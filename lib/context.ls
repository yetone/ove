require! {
    url
    './request': {Request}
    './response': {Response}
    \./utils
}

class Context implements Request, Response
    (req, resp, config = {}, g = {}) ->
        url-obj = url.parse req.url

        @req = req
        @resp = resp
        @config = config
        @g = g
        @url = req.url
        @method = req.method
        @search = url-obj.search
        @query = url-obj.query
        @pathname = url-obj.pathname
        @query-params = utils.query-str-to-obj url-obj.query
        @headers = req.headers
        @cookies = utils.parse-cookie req.headers.cookie
        @params = {}
        @form = {}
        @body = ''
        @ip = (req.headers[\x-forwarded-for] or '').split \, .0 or req.connection.remote-address
        @_resp-headers = {}
        @_resp-cookies = {}
        @_resp-charset = \UTF-8

exports.Context = Context
