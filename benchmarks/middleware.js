// Generated by LiveScript 1.3.1
(function(){
  var ove, app, n, body;
  ove = require('..');
  app = ove();
  n = parseInt(process.env.MW || '1', 10);
  console.log(' %s middleware', n);
  while (n--) {
    app.use(fn$);
  }
  body = new Buffer('Hello World');
  app.use(function(next){
    next();
    return this.body = body;
  });
  app.listen(3456);
  function fn$(next){
    return next();
  }
}).call(this);
