require! '../lib/utils'
require! \chai
chai.should!
chai.config.includeStack = true

describe \utils ->
    describe \.get-pattern-list (_) ->
        aaa = bbb = ccc = ddd = ->
        obj =
            'bpi':
                get: aaa
                post: bbb
                '/user':
                    get: ccc
                    post: ddd
                    name:
                        get: ccc
                        post: ddd
                        '/:name':
                            get: ccc
                        '/:age': ccc
                'people':
                    post: ccc
                    put: ccc
                    change: ccc
            '/api/':
                get: aaa
                post: bbb
                'user/':
                    get: ccc
                    post: ddd
                    '/name/':
                        get: ccc
                        post: ddd
                        ':name':
                            get: ccc
                            put: ccc

        list = utils.get-pattern-list obj

        it \list.length (done) ->
            list.length.should.be.equal 19
            done!

        it 'list[3][0]' (done) ->
            list[3][0].should.be.equal \/bpi/user/
            done!

        it 'list[5][0]' (done) ->
            list[5][0].should.be.equal \/bpi/user/name/
            done!

        it 'list[8][0]' (done) ->
            list[8][0].should.be.equal \/bpi/people/
            done!

        it 'list[8][2]' (done) ->
            list[8][2].should.be.eql <[ POST ]>
            done!

        it 'list[9][2]' (done) ->
            list[9][2].should.be.eql <[ PUT ]>
            done!
