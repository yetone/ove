var supertest, chai, ove;
supertest = require('supertest');
chai = require('chai');
chai.should();
chai.config.includeStack = true;
ove = require('..');
describe('ove', function(){
  var methodList;
  methodList = ['get', 'post', 'put', 'delete', 'patch', 'options'];
  describe('.use', function(_){
    it('should work with single func', function(done){
      var app, agent;
      app = ove();
      agent = supertest.agent(app.listen());
      app.use(function(it){
        this.send('response content');
        return it();
      });
      return agent.get('/').end(function(err, resp){
        resp.text.should.be.equal('response content');
        return done(err);
      });
    });
    it('should work with multi func', function(done){
      var app, agent, funcList;
      app = ove();
      agent = supertest.agent(app.listen());
      funcList = [];
      app.use(function(it){
        funcList.push('func1');
        return it();
      });
      app.use(function(it){
        funcList.push('func2');
        this.send('response content');
        return it();
      });
      app.use(function(it){
        funcList.push('func3');
        this.send('response content');
        return it();
      });
      return agent.get('/').end(function(err, resp){
        resp.text.should.be.equal('response content');
        funcList.join('|').should.be.equal(['func1', 'func2', 'func3'].join('|'));
        return done(err);
      });
    });
    return describe('should work with router', function(_){
      var app, agent;
      app = ove();
      agent = supertest.agent(app.listen());
      app.use('/home', function(){
        return this.send('home');
      });
      app.use('/user/name/:name/age/:age/', function(){
        return this.send('name: ' + this.params.name + ', age: ' + this.params.age);
      });
      it('GET /home', function(done){
        return agent.get('/home').end(function(err, resp){
          resp.text.should.be.equal('home');
          return done(err);
        });
      });
      it('GET /user/name/yetone/age/13/', function(done){
        return agent.get('/user/name/yetone/age/13/').end(function(err, resp){
          resp.text.should.be.equal('name: yetone, age: 13');
          return done(err);
        });
      });
      return it('GET /home/404', function(done){
        return agent.get('/home/404').expect(404).end(function(err, resp){
          resp.text.should.be.equal('Not found.');
          return done(err);
        });
      });
    });
  });
  describe('.register', function(_){
    describe('should work with object', function(_){
      var app, agent;
      app = ove();
      agent = supertest.agent(app.listen());
      app.register({
        '/api': {
          '/user': {
            get: function(){
              return this.send('GET /api/user/');
            },
            '/get': function(){
              return this.send('GET /api/user/get/');
            },
            '/name': {
              put: function(){
                return this.send('PUT /api/user/name/');
              },
              post: function(){
                return this.send('POST /api/user/name/');
              },
              change: function(){
                return this.send('GET /api/user/name/change/');
              }
            }
          },
          '/other': {
            get: function(){
              return this.send('GET /api/other/');
            },
            '/get': function(){
              return this.send('GET /api/other/get/');
            },
            '/name': {
              put: function(){
                return this.send('PUT /api/other/name/');
              },
              post: function(){
                return this.send('POST /api/other/name/');
              },
              change: function(){
                return this.send('GET /api/other/name/change/');
              }
            }
          }
        },
        '/api0': {
          '/user': {
            get: function(){
              return this.send('GET /api0/user/');
            },
            '/get': function(){
              return this.send('GET /api0/user/get/');
            },
            '/name': {
              put: function(){
                return this.send('PUT /api0/user/name/');
              },
              post: function(){
                return this.send('POST /api0/user/name/');
              },
              change: function(){
                return this.send('GET /api0/user/name/change/');
              }
            }
          },
          '/other': {
            get: function(){
              return this.send('GET /api0/other/');
            },
            '/get': function(){
              return this.send('GET /api0/other/get/');
            },
            '/name': {
              put: function(){
                return this.send('PUT /api0/other/name/');
              },
              post: function(){
                return this.send('POST /api0/other/name/');
              },
              change: function(){
                return this.send('GET /api0/other/name/change/');
              }
            }
          }
        }
      });
      it('GET /api/user/', function(done){
        return agent.get('/api/user/').end(function(err, resp){
          resp.text.should.be.equal('GET /api/user/');
          return done(err);
        });
      });
      it('GET /api/user/name/', function(done){
        return agent.get('/api/user/name/').end(function(err, resp){
          resp.text.should.be.equal('Method not allowed.');
          return done(err);
        });
      });
      it('GET /api0/user/get/', function(done){
        return agent.get('/api0/user/get/').end(function(err, resp){
          resp.text.should.be.equal('GET /api0/user/get/');
          return done(err);
        });
      });
      it('PUT /api0/user/name/', function(done){
        return agent.put('/api0/user/name/').end(function(err, resp){
          resp.text.should.be.equal('PUT /api0/user/name/');
          return done(err);
        });
      });
      it('POST /api0/user/name/', function(done){
        return agent.post('/api0/user/name/').end(function(err, resp){
          resp.text.should.be.equal('POST /api0/user/name/');
          return done(err);
        });
      });
      it('GET /api0/user/name/change/', function(done){
        return agent.get('/api0/user/name/change').end(function(err, resp){
          resp.text.should.be.equal('GET /api0/user/name/change/');
          return done(err);
        });
      });
      return it('GET /api0/other/', function(done){
        return agent.get('/api0/other/').end(function(err, resp){
          resp.text.should.be.equal('GET /api0/other/');
          return done(err);
        });
      });
    });
    describe('should work with multi handler list', function(_){
      var app, agent, handlerList, i$, ref$, len$, method, results$ = [];
      app = ove();
      agent = supertest.agent(app.listen());
      handlerList = [
        [
          '/', function(){
            return this.send('I am in /');
          }
        ], [
          '/user/:uid/', function(){
            return this.send('uid: ' + this.params.uid + ', method: ' + this.method);
          }, ['POST', 'delete']
        ], [
          '/form', function(){
            return this.send('form.name: ' + this.form.name + ', form.age: ' + this.form.age);
          }, 'POST'
        ], [
          '/other', function(){
            return this.send('I am in /other');
          }, ['put']
        ]
      ];
      for (i$ = 0, len$ = (ref$ = methodList).length; i$ < len$; ++i$) {
        method = ref$[i$];
        handlerList.push(fn$(method));
      }
      app.register(handlerList);
      it('GET /', function(done){
        return agent.get('/').end(function(err, resp){
          resp.text.should.be.equal('I am in /');
          return done(err);
        });
      });
      it('GET /asd', function(done){
        return agent.get('/asd').expect(404).end(function(err, resp){
          resp.text.should.be.equal('Not found.');
          return done(err);
        });
      });
      it('POST /user/yetone', function(done){
        return agent.post('/user/yetone').end(function(err, resp){
          resp.text.should.be.equal('uid: yetone, method: POST');
          return done(err);
        });
      });
      it('DELETE /user/ye%20tone/', function(done){
        return agent['delete']('/user/ye%20tone/').end(function(err, resp){
          resp.text.should.be.equal('uid: ye tone, method: DELETE');
          return done(err);
        });
      });
      it('GET /user/yetone/', function(done){
        return agent.get('/user/yetone/').end(function(err, resp){
          resp.text.should.be.equal('Method not allowed.');
          return done(err);
        });
      });
      it('POST /form', function(done){
        return agent.post('/form').send({
          name: 'yetone',
          age: 13
        }).end(function(err, resp){
          resp.text.should.be.equal('form.name: yetone, form.age: 13');
          return done(err);
        });
      });
      it('PUT /other/', function(done){
        return agent.put('/other/').end(function(err, resp){
          resp.text.should.be.equal('I am in /other');
          return done(err);
        });
      });
      it('GET /form', function(done){
        return agent.get('/form').expect(405).end(function(err, resp){
          resp.text.should.be.equal('Method not allowed.');
          return done(err);
        });
      });
      it('PUT /get', function(done){
        return agent.put('/get').expect(405).end(function(err, resp){
          resp.text.should.be.equal('Method not allowed.');
          return done(err);
        });
      });
      it('GET /delete', function(done){
        return agent.get('/delete').expect(405).end(function(err, resp){
          resp.text.should.be.equal('Method not allowed.');
          return done(err);
        });
      });
      for (i$ = 0, len$ = (ref$ = methodList).length; i$ < len$; ++i$) {
        method = ref$[i$];
        results$.push(fn1$(method));
      }
      return results$;
      function fn$(method){
        return [
          '/' + method, function(){
            return this.send('I am in /' + method);
          }, method
        ];
      }
      function fn1$(method){
        return it(method.toUpperCase() + ' /' + method, function(done){
          return agent[method]('/' + method).end(function(err, resp){
            resp.text.should.be.equal('I am in /' + method);
            return done(err);
          });
        });
      }
    });
    return describe('should work with single handler', function(_){
      var app, agent;
      app = ove();
      agent = supertest.agent(app.listen());
      app.register('/get/:id', function(){
        return this.send('I am in /get/' + this.params.id + ', queryParams.name: ' + this.queryParams.name + ', queryParams.age: ' + this.queryParams.age);
      });
      app.register('/post/:id', function(){
        return this.send('I am in /post/' + this.params.id + ', a: ' + this.form.a);
      }, 'post');
      app.register('/put/:id', function(){
        return this.send('I am in /put/' + this.params.id);
      }, ['put', 'options']);
      app.register('/user/:uid', function(){
        return this.send(this.pathname);
      }, 'get');
      it('GET /get/world?name=yetone&age=13', function(done){
        return agent.get('/get/world?name=yetone&age=13').end(function(err, resp){
          resp.text.should.be.equal('I am in /get/world, queryParams.name: yetone, queryParams.age: 13');
          return done(err);
        });
      });
      it('POST /post/world', function(done){
        return agent.post('/post/world').send({
          a: 1
        }).end(function(err, resp){
          resp.text.should.be.equal('I am in /post/world, a: 1');
          return done(err);
        });
      });
      it('PUT /put/world', function(done){
        return agent.put('/put/world').end(function(err, resp){
          resp.text.should.be.equal('I am in /put/world');
          return done(err);
        });
      });
      return it('GET /user/yetone', function(done){
        return agent.get('/user/yetone').end(function(err, resp){
          resp.text.should.be.equal('/user/yetone');
          return done(err);
        });
      });
    });
  });
  return describe('.(' + methodList.join('|') + ')', function(_){
    var app, agent, i$, ref$, len$, method, results$ = [];
    app = ove();
    agent = supertest.agent(app.listen());
    for (i$ = 0, len$ = (ref$ = methodList).length; i$ < len$; ++i$) {
      method = ref$[i$];
      fn$(method);
    }
    for (i$ = 0, len$ = (ref$ = methodList).length; i$ < len$; ++i$) {
      method = ref$[i$];
      results$.push(fn1$(method));
    }
    return results$;
    function fn$(method){
      return app[method]('/app/' + method, function(){
        return this.send('I am in /app/' + method);
      });
    }
    function fn1$(method){
      return it(method.toUpperCase() + ' /app/' + method, function(done){
        return agent[method]('/app/' + method).end(function(err, resp){
          resp.text.should.be.equal('I am in /app/' + method);
          return done(err);
        });
      });
    }
  });
});