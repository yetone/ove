var _, url, utils, getPatternList, Router, toString$ = {}.toString;
_ = require('prelude-ls');
url = require('url');
utils = require('./utils');
getPatternList = function(){
  return [];
};
Router = (function(){
  Router.displayName = 'Router';
  var prototype = Router.prototype, constructor = Router;
  function Router(){
    this.handlerList = [];
  }
  prototype.register = function(pattern, handler, methodList){
    var arr, i$, len$, item, paramRe, paramNames, that;
    arr = [];
    switch (toString$.call(pattern).slice(8, -1)) {
    case 'Array':
      arr = pattern;
      break;
    case 'Object':
      arr = getPatternList(pattern);
      break;
    default:
      arr.push([pattern, handler, methodList]);
    }
    for (i$ = 0, len$ = arr.length; i$ < len$; ++i$) {
      item = arr[i$];
      pattern = item[0], handler = item[1], methodList = item[2];
      switch (toString$.call(methodList).slice(8, -1)) {
      case 'Array':
        methodList = methodList.map(fn$);
        break;
      case 'String':
        methodList = [methodList.toUpperCase()];
        break;
      default:
        methodList = ['GET'];
      }
      paramRe = /:[^\/]+/g;
      if (pattern.replace(/[\/\w:\*]/g, '')) {
        throw new Error('The router pattern is error: ' + pattern);
      }
      paramNames = (that = pattern.match(paramRe))
        ? that.map(fn1$)
        : [];
      pattern = pattern.charAt(pattern.length - 1) === '/'
        ? pattern
        : pattern + '/';
      pattern = '^' + pattern + '$';
      pattern = pattern.replace(paramRe, '([^/]+)').replace(/\*/g, '[^\\/]*').replace(/\*\*/g, '.*').replace(/\//g, '\\/');
      pattern = new RegExp(pattern);
      this.handlerList.push([pattern, handler, methodList, paramNames]);
    }
    function fn$(method){
      return method.toUpperCase();
    }
    function fn1$(it){
      return it.slice(1);
    }
  };
  prototype.route = function(ctx){
    var self, pathname, matched, i$, ref$, len$, item, pattern, handler, methodList, paramNames, mArr, j$, len1$, idx, name, e;
    self = this;
    if (ctx.req.method === 'POST') {
      ctx.body = '';
      ctx.req.on('data', function(data){
        return ctx.body += data;
      });
    }
    pathname = url.parse(ctx.req.url).pathname;
    pathname = pathname.charAt(pathname.length - 1) === '/'
      ? pathname
      : pathname + '/';
    matched = false;
    for (i$ = 0, len$ = (ref$ = this.handlerList).length; i$ < len$; ++i$) {
      item = ref$[i$];
      pattern = item[0], handler = item[1], methodList = item[2], paramNames = item[3];
      mArr = pathname.match(pattern);
      if (!mArr) {
        continue;
      }
      matched = true;
      if (!in$(ctx.req.method, methodList)) {
        continue;
      }
      for (j$ = 0, len1$ = paramNames.length; j$ < len1$; ++j$) {
        idx = j$;
        name = paramNames[j$];
        try {
          ctx.params[name] = decodeURIComponent(mArr[idx + 1]);
        } catch (e$) {
          e = e$;
          ctx.params[name] = mArr[idx + 1];
        }
      }
      if (ctx.req.method === 'POST') {
        ctx.req.on('end', fn$);
        return;
      }
      handler.call(ctx);
      return;
    }
    if (matched) {
      ctx.sendStatus(405);
    } else {
      ctx.sendStatus(404);
    }
    function fn$(){
      ctx.form = utils.queryStrToObj(ctx.body);
      return handler.call(ctx);
    }
  };
  return Router;
}());
exports.Router = Router;
function in$(x, xs){
  var i = -1, l = xs.length >>> 0;
  while (++i < l) if (x === xs[i]) return true;
  return false;
}