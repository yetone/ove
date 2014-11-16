var http, Router, Context, logger, nodeStatic, Ove, slice$ = [].slice, toString$ = {}.toString;
http = require('http');
Router = require('./router').Router;
Context = require('./context').Context;
logger = require('./logger');
nodeStatic = require('node-static');
Ove = (function(){
  Ove.displayName = 'Ove';
  var prototype = Ove.prototype, constructor = Ove;
  function Ove(){
    var self, i$, ref$, len$, method;
    this.config = {
      cookieExpires: 30,
      cookieSecureToken: 'ove'
    };
    this.g = {};
    this.middlewares = [];
    this.server = http.createServer();
    this.router = new Router;
    self = this;
    for (i$ = 0, len$ = (ref$ = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS']).length; i$ < len$; ++i$) {
      method = ref$[i$];
      fn$(method);
    }
    function fn$(method){
      return self[method.toLowerCase()] = function(){
        var args;
        args = slice$.call(arguments);
        args.push([method]);
        return self.register.apply(self, args);
      };
    }
  }
  prototype.config = function(obj){
    import$(this.config, obj);
    return this;
  };
  prototype.register = function(){
    var args;
    args = slice$.call(arguments);
    this.router.register.apply(this.router, args);
    return this;
  };
  prototype.use = function(func){
    var idx, self;
    if (toString$.call(func).slice(8, -1) !== 'Function') {
      throw new Error('ove.use() expect a Function argument');
    }
    idx = this.middlewares.length + 1;
    self = this;
    this.middlewares.push(function(last){
      var ctx;
      ctx = this;
      func.call(ctx, function(){
        var that;
        if (that = self.middlewares[idx]) {
          return that.call(ctx, last);
        } else {
          return last.call(ctx);
        }
      });
    });
    return this;
  };
  prototype['static'] = function(pattern, path, opt){
    var self;
    this.staticServer = new nodeStatic.Server(path, opt);
    pattern = pattern.charAt(pattern.length - 1) === '/'
      ? pattern
      : pattern + '/';
    this.staticRe = new RegExp('^' + pattern.replace(/\//g, '\\/'));
    self = this;
    this.use(function(next){
      var ref$;
      if (!this.req.url.match(self.staticRe)) {
        next();
      }
      (ref$ = this.req).url = ref$.url.replace(self.staticRe, '');
      self.staticServer.serve(this.req, this.resp);
    });
    return this;
  };
  prototype.registerStatus = function(statusCode, handler){
    if (!this.config.statusHandlerMap) {
      this.config.statusHandlerMap = {};
    }
    this.config.statusHandlerMap[statusCode] = handler;
    return this;
  };
  prototype.listen = function(){
    var args, port, host, self;
    args = slice$.call(arguments);
    port = args[0], host = args[1];
    if (!port) {
      port = 8888;
    }
    if (!host) {
      host = '127.0.0.1';
    }
    self = this;
    this.server.on('request', function(req, resp){
      var ctx, that;
      ctx = new Context(req, resp, self.config, self.g);
      self.config.charset && ctx.setCharset(self.config.charset);
      if (that = self.middlewares[0]) {
        return that.call(ctx, function(){
          return self.router.route(ctx);
        });
      } else {
        return self.router.route(ctx);
      }
    });
    this.server.listen(port, host, function(){
      return logger.log("Ove app started.\nListening %s:%d", host, port);
    });
    return this;
  };
  prototype.run = function(){
    return this.listen.apply(this, arguments);
  };
  return Ove;
}());
module.exports = function(){
  return (function(func, args, ctor) {
    ctor.prototype = func.prototype;
    var child = new ctor, result = func.apply(child, args), t;
    return (t = typeof result)  == "object" || t == "function" ? result || child : child;
  })(Ove, arguments, function(){});
};
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}