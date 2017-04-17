require! <[ supertest chai ]>
chai.should!
chai.config.includeStack = true
ove = require '..'
port = 8080

describe \ove ->
    method-list = <[ get post put delete patch options ]>
    describe \.use (_) ->
        it 'should work with single func' (done) ->
            app = ove!
            agent = supertest.agent app.listen port++

            app.use ->
                @send 'response content'
                it!

            agent.get \/
                .end (err, resp) ->
                    resp.text.should.be.equal 'response content'
                    done err

        it 'should work with multi func' (done) ->
            app = ove!
            agent = supertest.agent app.listen port++

            func-list = []

            app.use ->
                func-list.push \func1
                it!

            app.use ->
                func-list.push \func2
                @send 'response content'
                it!

            app.use ->
                func-list.push \func3
                @send 'response content'
                it!

            agent.get \/
                .end (err, resp) ->
                    resp.text.should.be.equal 'response content'
                    func-list.join \| .should.be.equal <[ func1 func2 func3 ]>.join \|
                    done err

        describe 'should work with router' (_) ->
            app = ove!
            agent = supertest.agent app.listen port++

            app.use \/home ->
                @send \home

            app.use \/user/name/:name/age/:age/ ->
                @send 'name: ' + @params.name + ', age: ' + @params.age

            it 'GET /home' (done) ->
                agent.get \/home
                    .end (err, resp) ->
                        resp.text.should.be.equal \home
                        done err

            it 'GET /user/name/yetone/age/13/' (done) ->
                agent.get \/user/name/yetone/age/13/
                    .end (err, resp) ->
                        resp.text.should.be.equal 'name: yetone, age: 13'
                        done err

            it 'GET /home/404' (done) ->
                agent.get \/home/404
                    .expect 404
                    .end (err, resp) ->
                        resp.text.should.be.equal 'Not found.'
                        done err

    describe \.register (_) ->
        describe 'should work with object' (_) ->
            app = ove!
            agent = supertest.agent app.listen port++
            app.register do
                '/api':
                    '/user':
                        get: ->
                            @send 'GET /api/user/'
                        '/get': ->
                            @send 'GET /api/user/get/'
                        '/name':
                            put: ->
                                @send 'PUT /api/user/name/'
                            post: ->
                                @send 'POST /api/user/name/'
                            change: ->
                                @send 'GET /api/user/name/change/'
                    '/other':
                        get: ->
                            @send 'GET /api/other/'
                        '/get': ->
                            @send 'GET /api/other/get/'
                        '/name':
                            put: ->
                                @send 'PUT /api/other/name/'
                            post: ->
                                @send 'POST /api/other/name/'
                            change: ->
                                @send 'GET /api/other/name/change/'
                '/api0':
                    '/user':
                        get: ->
                            @send 'GET /api0/user/'
                        '/get': ->
                            @send 'GET /api0/user/get/'
                        '/name':
                            put: ->
                                @send 'PUT /api0/user/name/'
                            post: ->
                                @send 'POST /api0/user/name/'
                            change: ->
                                @send 'GET /api0/user/name/change/'
                    '/other':
                        get: ->
                            @send 'GET /api0/other/'
                        '/get': ->
                            @send 'GET /api0/other/get/'
                        '/name':
                            put: ->
                                @send 'PUT /api0/other/name/'
                            post: ->
                                @send 'POST /api0/other/name/'
                            change: ->
                                @send 'GET /api0/other/name/change/'

            it 'GET /api/user/' (done) ->
                agent.get \/api/user/
                    .end (err, resp) ->
                        resp.text.should.be.equal 'GET /api/user/'
                        done err

            it 'GET /api/user/name/' (done) ->
                agent.get \/api/user/name/
                    .end (err, resp) ->
                        resp.text.should.be.equal 'Method not allowed.'
                        done err

            it 'GET /api0/user/get/' (done) ->
                agent.get \/api0/user/get/
                    .end (err, resp) ->
                        resp.text.should.be.equal 'GET /api0/user/get/'
                        done err

            it 'PUT /api0/user/name/' (done) ->
                agent.put \/api0/user/name/
                    .end (err, resp) ->
                        resp.text.should.be.equal 'PUT /api0/user/name/'
                        done err

            it 'POST /api0/user/name/' (done) ->
                agent.post \/api0/user/name/
                    .end (err, resp) ->
                        resp.text.should.be.equal 'POST /api0/user/name/'
                        done err

            it 'GET /api0/user/name/change/' (done) ->
                agent.get \/api0/user/name/change
                    .end (err, resp) ->
                        resp.text.should.be.equal 'GET /api0/user/name/change/'
                        done err

            it 'GET /api0/other/' (done) ->
                agent.get \/api0/other/
                    .end (err, resp) ->
                        resp.text.should.be.equal 'GET /api0/other/'
                        done err

        describe 'should work with multi handler list' (_) ->
            app = ove!
            agent = supertest.agent app.listen port++

            handler-list = [
                * \/
                  ->
                      @send 'I am in /'
                * \/user/:uid/
                  ->
                      @send 'uid: ' + @params.uid + ', method: ' + @method
                  <[ POST delete ]>
                * \/form
                  ->
                      @send 'form.name: ' + @form.name + ', form.age: ' + @form.age
                  \POST
                * \/other
                  ->
                      @send 'I am in /other'
                  <[ put ]>
            ]

            for method in method-list
                handler-list.push ((method) ->
                    [
                        \/ + method
                        ->
                            @send 'I am in /' + method
                        method
                    ]
                ) method

            app.register handler-list

            it 'GET /' (done) ->
                agent.get \/
                    .end (err, resp) ->
                        resp.text.should.be.equal 'I am in /'
                        done err

            it 'GET /asd' (done) ->
                agent.get \/asd
                    .expect 404
                    .end (err, resp) ->
                        resp.text.should.be.equal 'Not found.'
                        done err

            it 'POST /user/yetone' (done) ->
                agent.post \/user/yetone
                    .end (err, resp) ->
                        resp.text.should.be.equal 'uid: yetone, method: POST'
                        done err

            it 'DELETE /user/ye%20tone/' (done) ->
                agent.delete '/user/ye%20tone/'
                    .end (err, resp) ->
                        resp.text.should.be.equal 'uid: ye tone, method: DELETE'
                        done err

            it 'GET /user/yetone/' (done) ->
                agent.get \/user/yetone/
                    .end (err, resp) ->
                        resp.text.should.be.equal 'Method not allowed.'
                        done err

            it 'POST /form' (done) ->
                agent.post \/form
                    .send {name: \yetone, age: 13}
                    .end (err, resp) ->
                        resp.text.should.be.equal 'form.name: yetone, form.age: 13'
                        done err

            it 'PUT /other/' (done) ->
                agent.put \/other/
                    .end (err, resp) ->
                        resp.text.should.be.equal 'I am in /other'
                        done err

            it 'GET /form' (done) ->
                agent.get \/form
                    .expect 405
                    .end (err, resp) ->
                        resp.text.should.be.equal 'Method not allowed.'
                        done err

            it 'PUT /get' (done) ->
                agent.put \/get
                    .expect 405
                    .end (err, resp) ->
                        resp.text.should.be.equal 'Method not allowed.'
                        done err

            it 'GET /delete' (done) ->
                agent.get \/delete
                    .expect 405
                    .end (err, resp) ->
                        resp.text.should.be.equal 'Method not allowed.'
                        done err

            for method in method-list
                ((method) ->
                    it method.to-upper-case! + ' /' + method, (done) ->
                        agent[method] \/ + method
                            .end (err, resp) ->
                                resp.text.should.be.equal 'I am in /' + method
                                done err
                ) method

        describe 'should work with single handler' (_) ->
            app = ove!
            agent = supertest.agent app.listen port++

            app.register do
                \/get/:id
                ->
                    @send 'I am in /get/' + @params.id + ', queryParams.name: ' + @query-params.name + ', queryParams.age: ' + @query-params.age

            app.register do
                \/post/:id
                ->
                    @send 'I am in /post/' + @params.id + ', a: ' + @form.a
                \post

            app.register do
                \/put/:id
                ->
                    @send 'I am in /put/' + @params.id
                <[ put options ]>

            app.register do
                \/user/:uid
                ->
                    @send @pathname
                \get

            it 'GET /get/world?name=yetone&age=13' (done) ->
                agent.get \/get/world?name=yetone&age=13
                    .end (err, resp) ->
                        resp.text.should.be.equal 'I am in /get/world, queryParams.name: yetone, queryParams.age: 13'
                        done err

            it 'POST /post/world' (done) ->
                agent.post \/post/world
                    .send({a: 1})
                    .end (err, resp) ->
                        resp.text.should.be.equal 'I am in /post/world, a: 1'
                        done err

            it 'PUT /put/world' (done) ->
                agent.put \/put/world
                    .end (err, resp) ->
                        resp.text.should.be.equal 'I am in /put/world'
                        done err

            it 'GET /user/yetone' (done) ->
                agent.get \/user/yetone
                    .end (err, resp) ->
                        resp.text.should.be.equal \/user/yetone
                        done err

    describe \.( + method-list.join(\|) + \), (_) ->
        app = ove!
        agent = supertest.agent app.listen port++
        for method in method-list
            ((method) ->
                app[method] \/app/ + method, ->
                    @send 'I am in /app/' + method
            ) method
        for method in method-list
            ((method) ->
                it method.to-upper-case! + ' /app/' + method, (done) ->
                    agent[method] \/app/ + method
                        .end (err, resp) ->
                            resp.text.should.be.equal 'I am in /app/' + method
                            done err
            ) method
