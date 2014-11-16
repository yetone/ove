var supertest, chai, ove;
supertest = require('supertest');
chai = require('chai');
chai.should();
chai.config.includeStack = true;
ove = require('..');
describe('ove', function(){
  return describe('.use', function(_){
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
        return agent.get('/home/404').end(function(err, resp){
          resp.text.should.be.equal('Not found.');
          return done(err);
        });
      });
    });
  });
});