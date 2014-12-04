_ = require 'lodash'
path = require 'path'
commander = require 'commander'
apiProvider = require './api_provider'
logger = require './logger'

commander
  .version('api_faker 0.0.4')
  .usage('[options] <file ...>')
  .option('-p, --port <port>', 'use the specified port', '8080')
  .option('-r, --proxy <proxy server url>', 'proxy the mismatch request to another server')
  .option('-v, --verbose', 'verbose output')

commander.on '--help', ->
  console.log '  Examples:'
  console.log ''
  console.log '    $ fakeApi api.json'
  console.log '    $ fakeApi api.js'
  console.log '    $ fakeApi api.json api2.json api3.js'
  console.log '    $ fakeApi api.json -p 80'
  console.log '    $ fakeApi api.json -p 80 -r http://localhost:8080'

commander.parse process.argv

if _.isEmpty(commander.args)
  commander.help()

logger.isVerbose = commander.verbose isnt undefined

port = parseInt(commander.port)
apiFiles = commander.args.map (apiFile) ->
  path.resolve process.cwd(), apiFile

apiProvider.init apiFiles

app = require('express')()

bodyParser = require 'body-parser'
multer = require 'multer'

app.use bodyParser.json() # for parsing application/json
app.use bodyParser.urlencoded({ extended: true }) # for parsing application/x-www-form-urlencoded
app.use multer() # for parsing multipart/form-data

if commander.proxy isnt undefined
  httpProxy = require 'http-proxy'
  proxy = httpProxy.createProxyServer({})

app.all /^(.+)$/, (req, res) ->
  # always allow cross domain
  res.header 'Access-Control-Allow-Origin', '*'

  path = req.params[0]
  params = {}
  _.each [req.query, req.body], (p) ->
    _.assign params, p
  dataResult = apiProvider.getApiData(path, req.method, params)
  if dataResult.found
    logger.info "[Hitted] #{dataResult.hitted}"
    logger.verbose '[Result]'
    logger.verbose dataResult.result
    logger.verbose ''
    res.send(dataResult.result)
  else
    logger.info "[Not Found] [#{req.method}]#{path}"
    if commander.proxy isnt undefined
      proxy.web req, res, {target: commander.proxy}
      logger.verbose "[Proxy To] #{commander.proxy}\n"
    else
      res.status(404)
      res.send()

app.listen port
logger.info "API Faker server listening at port: #{port}\n"
