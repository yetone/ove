require! \crypto

module.exports =
    query-str-to-obj: (str) ->
        res = {}
        if typeof! str is not \String
            return res
        pair-lst = str.split \&
        for pair in pair-lst
            kv-lst = pair.split \=
            if kv-lst.length is not 2
                continue
            [k, v] = kv-lst
            try
                res[k.trim!] = decodeURIComponent v
            catch
                res[k.trim!] = v
        res

    obj-to-query-str: (obj) ->
        acc = []
        for key, item of obj
            if not obj.has-own-property key
                continue
            acc.push key + \= + item
        acc.join \&

    parse-cookie: (str) ->
        res = {}
        if typeof! str is not \String
            return res
        pair-lst = str.split \;
        for pair in pair-lst
            kv-lst = pair.split \=
            if kv-lst.length is not 2
                continue
            [k, v] = kv-lst
            res[k.trim!] = v
        res

    hex-hmac-sha1: (data, key = '*') ->
        hmac = crypto.create-hmac \sha1 key
        hmac.update data
        hmac.digest \hex

    base64: do
        encode: (str) ->
            (new Buffer str).to-string \base64
        decode: (str) ->
            (new Buffer str, \base64).to-string \utf8

    def-protected: (obj, key, val, enumerable, writable) !->
        Object.define-property obj, key, do
            value: val
            enumerable: enumerable
            writable: writable
            configurable: true

    make-protected: (obj) !->
        descs = {}
        for own key, val of obj
            descs[key] =
                value: val
                +configurable

        Object.define-properties obj, descs

