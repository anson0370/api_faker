apiProvider = require '../src/api_provider'
should = require 'should'
path = require 'path'

describe 'api_provider', ->
  before ->
    apiProvider.init [path.resolve(process.cwd(), 'api.js')]

  it 'should hit url correct', ->
    result = apiProvider.getApiData('/api/users', 'GET', {})
    result.found.should.be.equal(true)
    result.hitted.should.be.equal('[GET]/api/users')
    result.result.should.be.eql({
      name: "wtf"
      })

  it 'should match the right method', ->
    result = apiProvider.getApiData('/api/users', 'POST', {})
    result.found.should.be.equal(true)
    result.hitted.should.be.equal('[POST, PUT]/api/users')

    result = apiProvider.getApiData('/api/users', 'PUT', {})
    result.found.should.be.equal(true)
    result.hitted.should.be.equal('[POST, PUT]/api/users')

  it 'should call the result function and pass the url params', ->
    result = apiProvider.getApiData('/api/user/12', 'GET', {})
    result.found.should.be.equal(true)
    result.hitted.should.be.equal('[GET]/api/user/:id')
    result.result.should.be.eql({
      id: "12"
      })

  it 'should hit the accurater api', ->
    result = apiProvider.getApiData('/api/user/special', 'GET', {})
    result.found.should.be.equal(true)
    result.hitted.should.be.equal('[GET]/api/user/special')

  it 'should hit an api specified ALL methods', ->
    result = apiProvider.getApiData('/api/all_methods', 'TRACE', {})
    result.found.should.be.equal(true)
    result.hitted.should.be.equal('[ALL]/api/all_methods')

  it 'should return {found:false} if not hit', ->
    result = apiProvider.getApiData('/api/not_exists', 'GET', {})
    result.found.should.be.equal(false)

  describe 'load json file', ->
    before ->
      apiProvider.init [path.resolve(process.cwd(), 'api.json')]

    it 'should load and play like js file', ->
      result = apiProvider.getApiData('/api/orders', 'GET', {})
      result.found.should.be.equal(true)
      result.hitted.should.be.equal('[GET]/api/orders')
      result.result.should.be.eql({
        name: "wtf"
        })

  describe 'load multiple files', ->
    before ->
      apiProvider.init [path.resolve(process.cwd(), 'api.js'), path.resolve(process.cwd(), 'api.json')]

    it 'should match in all these files', ->
      result = apiProvider.getApiData('/api/users', 'GET', {})
      result.found.should.be.equal(true)
      result.hitted.should.be.equal('[GET]/api/users')

      result = apiProvider.getApiData('/api/orders', 'GET', {})
      result.found.should.be.equal(true)
      result.hitted.should.be.equal('[GET]/api/orders')
