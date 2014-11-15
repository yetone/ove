#ove

A powerful Node.js web framework.

## Installation

```
npm install ove
```

## Example

Use LiveScript:

```js
require! \ove
app = ove!

app.use (next) ->
    console.log '%s [%s] %s', new Date, @method, @url
    next!

app.get \/user/:uid/ ->
    @json do
        uid: @params.uid

app.post \/user/create/ ->
    @json @form

app.run!
```
