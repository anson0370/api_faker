fs = require 'fs'
path = require 'path'
fileWatcher = require './file_watcher'
_ = require 'lodash'
logger = require './logger'

class Api
  constructor: (url, result) ->
    @description = url
    @result = result
    urlMatchResult = /^\[\s*([A-Z]+(\s*,\s*[A-Z]+)*)\s*\]\s*(\/\S*)$/.exec(url)
    if urlMatchResult is null
      throw 'url format error'
    if urlMatchResult[1] is undefined
      @methods = ['ALL']
    else
      @methods = urlMatchResult[1].split(',').map (method) ->
        method.trim()
    @url = urlMatchResult[3]

  match: (targetUrl, method) ->
    if not _.contains(@methods, 'ALL') and not _.contains(@methods, method)
      return {
        mismatch: true
      }
    splitExceptUrl = @url.substring(1).split('/')
    splitTargetUrl = targetUrl.substring(1).split('/')
    if splitExceptUrl.length isnt splitTargetUrl.length
      return {
        mismatch: true
      }
    placeholders = {}
    mismatch = false
    _.each splitExceptUrl, (exceptFragment, index) ->
      targetFragment = splitTargetUrl[index]
      if /^:/.test exceptFragment
        placeholders[exceptFragment.substring(1)] = targetFragment
        return true
      if exceptFragment isnt splitTargetUrl[index]
        mismatch = true
        return false
    if mismatch
      return {
        mismatch: true
      }
    return {
      mismatch: false
      placeholders: placeholders
    }

  getResult: (url, method, params) ->
    if _.isFunction(@result)
      @result(url, method, params)
    else
      @result

apiDatas = {}
inited = false

module.exports =
  init: (apiFilePaths) ->
    apiDatas = {}
    inited = false

    loadData = (apiFilePath) ->
      if fs.existsSync(apiFilePath)
        data = require(apiFilePath)
        apiDatas[apiFilePath] = _.map data, (v, k) -> new Api(k, v)
        logger.verbose "[File Loaded] #{apiFilePath}"
      else
        logger.info "[File Not Exists] #{apiFilePath}"


    _.each apiFilePaths, loadData
    logger.info ''

    fileWatcher.watchFiles apiFilePaths, (apiFilePath) ->
      require.cache[apiFilePath] = null # clear module cache to reload module
      try
        loadData(apiFilePath)
        logger.info("[File Reload] #{apiFilePath}")
      catch err
        logger.info("[File Reload Error] #{apiFilePath} - #{err}")

    inited = true

  getApiData: (url, method, params) ->
    throw 'call init(apiFilePaths) before get data' unless inited

    isAccuraterThen = (matchResult1, matchResult2) ->
      _.size(matchResult1.placeholders) < _.size(matchResult2.placeholders)

    targetApi = undefined
    matchedResult = undefined
    _.each apiDatas, (apis) ->
      skip = false
      _.each apis, (api) ->
        matchResult = api.match(url, method)
        return true if matchResult.mismatch
        if _.size(matchResult.placeholders) is 0
          skip = true
          targetApi = api
          matchedResult = matchResult
          return false
        if matchedResult is undefined or isAccuraterThen(matchResult, matchedResult)
          targetApi = api
          matchedResult = matchResult
        return true

      return false if skip

    if targetApi is undefined
      return {
        found: false
      }

    _.assign params, matchedResult.placeholders

    {
      found: true
      hitted: targetApi.description
      result: targetApi.getResult(url, method, params)
    }
