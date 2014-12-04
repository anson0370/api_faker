_ = require 'lodash'
path = require 'path'
commander = require 'commander'
express = require 'express'
apiProvider = require './api_provider'
logger = require './logger'

commander
  .version('api_faker 0.0.2')
  .usage('[options] <file ...>')
  .option('-p, --port <port>', 'use the specified port', '8080')
  .option('-v, --verbose', 'verbose output')

commander.on '--help', ->
  console.log '  Examples:'
  console.log ''
  console.log '    $ fakeApi api.json'
  console.log '    $ fakeApi api.js'
  console.log '    $ fakeApi api.json api2.json api3.js'
  console.log '    $ fakeApi api.json -p 80'

commander.parse process.argv

if _.isEmpty(commander.args)
  commander.help()

logger.isVerbose = commander.verbose isnt undefined

port = parseInt(commander.port)
apiFiles = commander.args.map (apiFile) ->
  path.resolve process.cwd(), apiFile

apiProvider.init apiFiles

app = express()

app.all /^(.+)$/, (req, res) ->
  # always allow cross domain
  res.header 'Access-Control-Allow-Origin', '*'

  path = req.params[0]
  dataResult = apiProvider.getApiData(path, req.method, req.query)
  if dataResult.found
    logger.info "[Hitted] #{dataResult.hitted}"
    logger.verbose '[Result]'
    logger.verbose dataResult.result
    logger.verbose ''
    res.send(dataResult.result)
  else
    logger.info "[Not Found] [#{req.method}]#{path}"
    res.status(404)
    res.send()

app.listen port
logger.info "API Faker server listening at port: #{port}\n"
