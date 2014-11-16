var logger, utils, statusMap, toString$ = {}.toString;
logger = require('./logger');
utils = require('./utils');
statusMap = {
  404: 'Not found.',
  405: 'Method not allowed.',
  502: 'Server Error.'
};
exports.Response = {
  setCharset: function(_respCharset){
    this._respCharset = _respCharset;
  },
  setHeader: function(key, value){
    var obj;
    obj = key;
    if (toString$.call(key).slice(8, -1) !== 'Object') {
      obj = {};
      obj[key] = value;
    }
    import$(this._respHeaders, obj);
  },
  setCookie: function(key, value, opt){
    var dft, header, exDate;
    dft = {
      path: '/',
      expires: this.config.cookieExpires,
      domain: undefined,
      httpOnly: true,
      secure: false,
      overwrite: false
    };
    switch (toString$.call(opt).slice(8, -1)) {
    case 'Number':
      opt = import$(dft, {
        expires: opt
      });
      break;
    case 'Object':
      opt = import$(dft, opt);
      break;
    default:
      opt = dft;
    }
    header = key + '=' + value;
    if (opt.path) {
      header += '; path=' + opt.path;
    }
    if (opt.expires) {
      exDate = new Date;
      exDate.setDate(exDate.getDate() + opt.expires);
      header += '; expires=' + exDate.toUTCString();
    }
    if (opt.domain) {
      header += '; domain' + opt.domain;
    }
    if (opt.secure) {
      header += '; secure';
    }
    if (opt.httpOnly) {
      header += '; httponly';
    }
    this._respCookies[key] = header;
  },
  setSecureCookie: function(key, value, opt){
    var expires, signature;
    expires = this.config.cookieExpires;
    switch (toString$.call(opt).slice(8, -1)) {
    case 'Number':
      expires = opt;
      break;
    case 'Object':
      expires = opt.expires || expires;
    }
    value = [value.length, utils.base64.encode(value), Date.now() + expires * 60 * 60 * 24];
    signature = utils.hexHmacSha1(value.join('|'), this.config.cookieSecureToken);
    value.push(signature);
    value = value.join('|').replace(/\=/g, '*');
    this.setCookie(key, value, opt);
  },
  send: function(statusCode, content){
    var ref$, cookieAcc, _, item;
    if (toString$.call(statusCode).slice(8, -1) !== 'Number') {
      ref$ = [200, statusCode], statusCode = ref$[0], content = ref$[1];
    }
    cookieAcc = [];
    for (_ in ref$ = this._respCookies) {
      item = ref$[_];
      cookieAcc.push(item);
    }
    import$(this._respHeaders, {
      'Set-Cookie': cookieAcc
    });
    this.resp.writeHead(statusCode, this._respHeaders);
    this.resp.end(content);
  },
  json: function(statusCode, obj){
    var ref$, str, message, error;
    if (toString$.call(statusCode).slice(8, -1) !== 'Number') {
      ref$ = [200, statusCode], statusCode = ref$[0], obj = ref$[1];
    }
    this.setHeader('Content-Type', 'application/json; charset=' + this._respCharset);
    try {
      str = JSON.stringify(obj);
    } catch (e$) {
      message = e$.message;
      error = 'response.json require a Object param can be stringified to string';
      logger.error(error);
      return;
    }
    this.send(statusCode, str);
  },
  html: function(statusCode, str){
    var ref$;
    if (toString$.call(statusCode).slice(8, -1) !== 'Number') {
      ref$ = [200, statusCode], statusCode = ref$[0], str = ref$[1];
    }
    this.setHeader('Content-Type', 'text/html; charset=' + this._respCharset);
    this.send(statusCode, str);
  },
  redirect: function(url){
    this.setHeader('Location', url);
    this.send(302);
  },
  sendStatus: function(statusCode){
    var that, ref$;
    if (that = (ref$ = this.config.statusHandlerMap) != null ? ref$[statusCode] : void 8) {
      that.call(this);
      return;
    }
    if (that = statusMap[statusCode]) {
      this.send(statusCode, that);
    }
  }
};
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}