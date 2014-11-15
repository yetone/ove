require! \./utils

exports.Request = do
    get-cookie: (key, dft) ->
        @cookies[key] or dft

    get-secure-cookie: (key, dft) ->
        value = @cookies[key]
        if not value
            return dft

        parts = value.replace /\*/g \= .split \|
        if parts.length is not 4
            return dft

        [len, value, expires, signature] = parts
        value = utils.base64.decode value .substr 0 len

        if +expires < Date.now!
            return dft

        local-sig = utils.hex-hmac-sha1 (parts.slice 0 3 .join \|), @config.cookie-secure-token

        if local-sig is not signature
            logger.error 'invalid cookie signature: ' + key
            return dft

        value
