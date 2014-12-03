watch = require "node-watch"
_ = require "lodash"

module.exports =
  watchFiles: (filePaths, callback) ->
    if _.isArray(filePaths)
      _.each filePaths, (filePath) ->
        watch filePath, callback
    else
      watch filePaths, callback
