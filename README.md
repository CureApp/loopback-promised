# loopback-promised

  loopback-promised is an HTTP client for StrongLoop Loopback using __ES6 Promise__ Available in __Web__, __Node.js__ and __Titanium__.

[latest API documentation Page](http://cureapp.github.io/loopback-promised/doc/v0.2.0/index.html)

## Installation

```bash
$ npm install loopback-promised
```

### Node.js

```js
var LoopbackPromised = require('loopback-promised')
```

### Titanium

```bash
$ cp /path/to/this-module/dist/loopback-promised.titanium.js /path/to/your-project/app/lib/
```
```js
var LoopbackPromised = require('loopback-promised')
```

### Web browsers

```bash
$ cp /path/to/this-module/dist/loopback-promised.web.js /path/to/your-project/
```

```html
<script type="text/javascript" charset="utf-8" src="/path/to/your-project/loopback-promised.web.js"></script>
<script type="text/javascript">console.log(LoopbackPromised);</script>
```

### use a minified one in Web browsers

```bash
$ cp /path/to/this-module/dist/loopback-promised.min.js /path/to/your-project/
```

```html
<script type="text/javascript" charset="utf-8" src="/path/to/your-project/loopback-promised.min.js"></script>
<script type="text/javascript">console.log(LoopbackPromised);</script>
```

### install this project from github

(requires [grunt-cli](https://github.com/gruntjs/grunt-cli))

```bash
$ git clone https://github.com/CureApp/loopback-promised.git
$ cd loopback-promised
$ npm install
$ npm install -g grunt-cli # skip if you already have one
$ grunt build
```




# Usage

```coffee
LoopbackPromised = require('loopback-promised') # (in web browsers, this should be omitted)

lbPromised = LoopbackPromised.createInstance
    baseURL: 'http://localhost:3000'

client = lbPromised.createClient('notebooks')

client.create(name: 'Biology').then (notebook) ->
    console.log notebook.id
    console.log notebook.name
```


## API documentations
- [v0.2.0](http://cureapp.github.io/loopback-promised/doc/v0.2.0/index.html)
- [v0.1.1](http://cureapp.github.io/loopback-promised/doc/v0.1.1/index.html)
- [v0.0.15](http://cureapp.github.io/loopback-promised/doc/v0.0.15/index.html)


# test

(requires [grunt-cli](https://github.com/gruntjs/grunt-cli))

```
$ grunt
```



## License

  MIT

