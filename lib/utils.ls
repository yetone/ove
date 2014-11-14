module.exports = do
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
            res[k.trim!] = decodeURIComponent v
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

