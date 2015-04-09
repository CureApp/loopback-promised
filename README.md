# loopback-promised

  loopback-promised is an HTTP client for StrongLoop LoopBack using __ES6 Promise__ Available in __Web__, __Node.js__ and __Titanium__.

[latest API documentation Page](http://cureapp.github.io/loopback-promised/doc/v0.1.0/index.html)

## Installation

```bash
$ npm install loopback-promised
```

### Node.js

```js
var LoopBackPromised = require('loopback-promised')
```

### Titanium

```bash
$ cp /path/to/this-module/dist/loopback-promised.titanium.js /path/to/your-project/app/lib/
```
```js
var LoopBackPromised = require('loopback-promised')
```

### Web browsers

```bash
$ cp /path/to/this-module/dist/loopback-promised.web.js /path/to/your-project/
```

```html
<script type="text/javascript" charset="utf-8" src="/path/to/your-project/loopback-promised.web.js"></script>
<script type="text/javascript">console.log(LoopBackPromised);</script>
```

### use a minified one in Web browsers

```bash
$ cp /path/to/this-module/dist/loopback-promised.min.js /path/to/your-project/
```

```html
<script type="text/javascript" charset="utf-8" src="/path/to/your-project/loopback-promised.min.js"></script>
<script type="text/javascript">console.log(LoopBackPromised);</script>
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
LoopBackPromised = require('loopback-promised') # (in web browsers, this should be omitted)

lbPromised = LoopBackPromised.createInstance
    baseURL: 'http://localhost:3000'

client = lbPromised.createClient('notebooks')

client.create(name: 'Biology').then (notebook) ->
    console.log notebook.id
    console.log notebook.name
```


## API documentations
- [v0.1.0](http://cureapp.github.io/loopback-promised/doc/v0.1.0/index.html)
- [v0.0.15](http://cureapp.github.io/loopback-promised/doc/v0.0.15/index.html)


# test

(requires [grunt-cli](https://github.com/gruntjs/grunt-cli))

```
$ grunt
```



## License

  MIT

