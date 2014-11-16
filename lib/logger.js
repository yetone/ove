module.exports = {
  log: function(){
    return console.log.apply(this, arguments);
  },
  info: function(){
    return console.info.apply(this, arguments);
  },
  error: function(){
    return console.error.apply(this, arguments);
  }
};