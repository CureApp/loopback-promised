# loopback-promised

  loopback-promised is an HTTP client for StrongLoop LoopBack using __ES6 Promise__ Available in __Web__, __Node.js__ and __Titanium__.

## Installation

node.js:

```bash
$ npm install loopback-promised
```

titanium:

```
$ npm install -g loopback-promised
$ loopback-promised titaniumify > loopback-promised.js # incoming
```

web:

```
$ npm install -g loopback-promised
$ loopback-promised browserify > loopback-promised.js # incoming
```


# Usage

```coffee
LoopBackPromised = require('loopback-promised')

lbPromised = LoopBackPromised.createInstance
    baseURL: 'localhost:3000'

client = lbPromised.createClient('notebooks')

client.create(name: 'Biology').then (notebook) ->
    console.log notebook.id
    console.log notebook.name
```

## more docs

see [API documentation Page](https://cureapp.github.io/loopback-promised)

# test
```
$ grunt
```


## License

  MIT
