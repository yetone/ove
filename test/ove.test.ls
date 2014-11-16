require! <[ supertest chai ]>
chai.should!
chai.config.includeStack = true
ove = require '..'

describe \ove ->
    describe \.use (_) ->
        it 'should work with single func' (done) ->
            app = ove!
            agent = supertest.agent app.listen!

            app.use ->
                @send 'response content'
                it!

            agent.get \/
                .end (err, resp) ->
                    resp.text.should.be.equal 'response content'
                    done err

        it 'should work with multi func' (done) ->
            app = ove!
            agent = supertest.agent app.listen!

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
            agent = supertest.agent app.listen!

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
                    .end (err, resp) ->
                        resp.text.should.be.equal 'Not found.'
                        done err
