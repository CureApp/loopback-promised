# loopback-promised

  loopback-promised is an HTTP client for StrongLoop Loopback using Promise.

## Universal JS
This project is universal (in past, called "isomorphic").
Bundle into your project and it runs.

[latest API documentation Page](http://cureapp.github.io/loopback-promised/index.html)

## Installation

```bash
$ npm install loopback-promised
```

## Usage

```js
var LoopbackPromised = require('loopback-promised')

var lbPromised = LoopbackPromised.createInstance({
  baseURL: 'http://localhost:3000'
});

var client = lbPromised.createClient('notebooks')

client.create({name: 'Biology'}).then(function(notebook) {
  console.log(notebook.id)
  console.log(notebook.name)
})
```

## License

  MIT

