# API Faker

Easy to fake http api.

## Features

- Standalone http server to provide fake apis.
- Load `.js` and `.json` file.
- Watch and reload `.js` and `.json` file. (only tested at OSX)
- Proxy mismatch request to another server.

## Install

`$ npm install -g api_faker`

## Usage

```
$ fakeApi -h

  Usage: index.coffee [options] <file ...>

  Options:

    -h, --help                      output usage information
    -V, --version                   output the version number
    -p, --port <port>               use the specified port
    -r, --proxy <proxy server url>  proxy the mismatch request to another server
    -v, --verbose                   verbose output

  Examples:

    $ fakeApi api.json
    $ fakeApi api.js
    $ fakeApi api.json api2.json api3.js
    $ fakeApi api.json -p 80
    $ fakeApi api.json -p 80 -r http://localhost:8080
```

example:

```
$ fakeApi api.js
```

api.js:

```js
module.exports = {
  "[GET]/api/users": {
    name: "wtf"
  },
  "[GET]/api/user/:id": function(url, method, params) {
    return {
      id: params.id
    };
  }
}
```

use:

```
$ curl -XGET http://127.0.0.1:8080/api/users
{"name":"wtf"}

$ curl -XGET http://127.0.0.1:8080/api/user/1
{"id":"1"}
```

## API file

Support `.js` and `.json` file.

### .js

```js
module.exports = {
  "[GET]/api/users": {
    name: "wtf"
  },
  "[GET]/api/user/:id": function(url, method, params) {
    return {
      id: params.id
    };
  }
}
```

### .json

```json
{
  "[GET]/api/orders": {
    "name": "wtf"
  }
}
```

### pattern

```
^\[\s*([A-Z]+(\s*,\s*[A-Z]+)*)\s*\]\s*(\/\S*)$
```

base:

```
[GET]/api/users
```

multi methods:

```
[GET,PUT,POST]/api/users
```

all methods:

```
[ALL]/api/users
```

path variable:

```
[GET]/api/user/:userId/address/:addressId
```

## Workflow

1. leave all `.js` files in `lib/` folder there
2. write code with coffee in `src/` folder
3. write test code with coffee in `test/` folder
4. run `npm test`, make sure all tests passed
5. use `npm run compile` to compile coffee to js
6. commit and push to git

To compile and install the repo, use `npm run build`.
