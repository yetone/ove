var utils, chai;
utils = require('../lib/utils');
chai = require('chai');
chai.should();
chai.config.includeStack = true;
describe('utils', function(){
  return describe('.get-pattern-list', function(_){
    var aaa, bbb, ccc, ddd, obj, list;
    aaa = bbb = ccc = ddd = function(){};
    obj = {
      'bpi': {
        get: aaa,
        post: bbb,
        '/user': {
          get: ccc,
          post: ddd,
          name: {
            get: ccc,
            post: ddd,
            '/:name': {
              get: ccc
            },
            '/:age': ccc
          }
        },
        'people': {
          post: ccc,
          put: ccc,
          change: ccc
        }
      },
      '/api/': {
        get: aaa,
        post: bbb,
        'user/': {
          get: ccc,
          post: ddd,
          '/name/': {
            get: ccc,
            post: ddd,
            ':name': {
              get: ccc,
              put: ccc
            }
          }
        }
      }
    };
    list = utils.getPatternList(obj);
    it('list.length', function(done){
      list.length.should.be.equal(19);
      return done();
    });
    it('list[3][0]', function(done){
      list[3][0].should.be.equal('/bpi/user/');
      return done();
    });
    it('list[5][0]', function(done){
      list[5][0].should.be.equal('/bpi/user/name/');
      return done();
    });
    it('list[8][0]', function(done){
      list[8][0].should.be.equal('/bpi/people/');
      return done();
    });
    it('list[8][2]', function(done){
      list[8][2].should.be.eql(['POST']);
      return done();
    });
    return it('list[9][2]', function(done){
      list[9][2].should.be.eql(['PUT']);
      return done();
    });
  });
});