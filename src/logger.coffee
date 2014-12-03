_ = require 'lodash'

module.exports =
  isVerbose: false

  info: (log) ->
    console.log if _.isFunction(log) then log() else log

  verbose: (log) ->
    @info(log) if @verbose
