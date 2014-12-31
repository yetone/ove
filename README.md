#ove [![](https://codeship.com/projects/a4ff18c0-72d7-0132-d565-5ad4053fa8e4/status?branch=master)](https://codeship.com/projects/54852)

A powerful Node.js web framework.

## Installation

```
npm install ove
```

## Example

### Use LiveScript:

```js
require! \ove
app = ove!

app.use (next) ->
    console.log '%s [%s] %s', new Date, @method, @url
    next!

app.get \/ ->
    @send 'Hello ove!'

app.get \/user/:uid/ ->
    @json do
        uid: @params.uid

app.post \/user/create/ ->
    @json @form

app.run!
```

### Use JavaScript:

```js
var ove = require('ove');
app = ove();

app.use(function(next) {
    console.log('%s [%s] %s', new Date(), this.method, this.url);
    next();
});

app.get('/', function() {
    this.send('Hello ove!');
});

app.get('/user/:uid/', function() {
    this.json({
        uid: this.params.uid
    });
});

app.post('/user/create/', function() {
    this.json(this.form);
});

app.run();
```
