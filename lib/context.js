var url, Request, Response, utils, Context;
url = require('url');
Request = require('./request').Request;
Response = require('./response').Response;
utils = require('./utils');
Context = (function(){
  Context.displayName = 'Context';
  var prototype = Context.prototype, constructor = Context;
  importAll$(prototype, arguments[0]);
  importAll$(prototype, arguments[1]);
  function Context(req, resp, config, g){
    var urlObj;
    config == null && (config = {});
    g == null && (g = {});
    urlObj = url.parse(req.url);
    this.req = req;
    this.resp = resp;
    this.config = config;
    this.g = g;
    this.url = req.url;
    this.method = req.method;
    this.search = urlObj.search;
    this.query = urlObj.query;
    this.pathname = urlObj.pathname;
    this.queryParams = utils.queryStrToObj(urlObj.query);
    this.headers = req.headers;
    this.cookies = utils.parseCookie(req.headers.cookie);
    this.params = {};
    this.form = {};
    this.body = '';
    this.ip = (req.headers['x-forwarded-for'] || '').split(',')[0] || req.connection.remoteAddress;
    this._respHeaders = {};
    this._respCookies = {};
    this._respCharset = 'UTF-8';
  }
  return Context;
}(Request, Response));
exports.Context = Context;
function importAll$(obj, src){
  for (var key in src) obj[key] = src[key];
  return obj;
}