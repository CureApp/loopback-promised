
LoopBackPromised      = require '../src/loopback-promised'
LoopBackClient        = require '../src/loopback-client'
LoopBackUserClient    = require '../src/loopback-user-client'
LoopBackRelatedClient = require '../src/loopback-related-client'

before (done) ->
    @timeout 5000
    require('./init').then -> done()

debug = false


baseURL = 'localhost:4157/test-api'

describe 'LoopBackPromised', ->


    describe 'request', ->

        it 'cannot request to the server when baseURL is not set', ->

            lbPromised = LoopBackPromised.createInstance()

            pluralModelName = 'notebooks'
            path            = ''
            params          = null
            http_method     = 'GET'
            clientInfo      =
                accessToken: null
                debug: debug

            lbPromised.request(pluralModelName, path, params, http_method, clientInfo).then (responseBody) ->
                done new Error('this cannot occur')
            .catch (e) ->
                expect(e.message).to.match('baseURL')
                done()


        it 'fails if baseURL is not valid (port)', ->

            lbPromised = LoopBackPromised.createInstance
                baseURL: 'localhost:4158/api' # invalid URL

            pluralModelName = 'notebooks'
            path            = ''
            params          = null
            http_method     = 'GET'
            clientInfo      =
                accessToken: null
                debug: debug

            lbPromised.request(pluralModelName, path, params, http_method, clientInfo).then (responseBody) ->
                done new Error('this cannot occur')
            .catch (e) ->
                expect(e).to.have.property('code', 'ECONNREFUSED')
                done()

        it 'fails if baseURL is not valid (path)', ->

            lbPromised = LoopBackPromised.createInstance
                baseURL: 'localhost:4157/api' # invalid URL

            pluralModelName = 'notebooks'
            path            = ''
            params          = null
            http_method     = 'GET'
            clientInfo      =
                accessToken: null
                debug: debug

            lbPromised.request(pluralModelName, path, params, http_method, clientInfo).then (responseBody) ->
                done new Error('this cannot occur')
            .catch (e) ->
                expect(e.name).to.match('Cannot GET')
                done()



        it 'requests to the server', (done) ->

            lbPromised = LoopBackPromised.createInstance
                baseURL: baseURL

            pluralModelName = 'notebooks'
            path            = ''
            params          = null
            http_method     = 'GET'
            clientInfo      =
                accessToken: null
                debug: debug

            lbPromised.request(pluralModelName, path, params, http_method, clientInfo).then (responseBody) ->
                expect(responseBody).to.be.instanceof Array
                done()
            .catch (e) ->
                done e

    describe 'createClient', ->

        it 'creates client for one model', ->

            lbPromised = LoopBackPromised.createInstance
                baseURL: baseURL

            pluralModelName = 'notebooks'

            clientInfo      =
                accessToken: null
                debug: debug

            client = lbPromised.createClient(pluralModelName, clientInfo)

            expect(client).to.be.instanceof LoopBackClient


        it 'creates related client when "belongsTo" option is set', ->

            lbPromised = LoopBackPromised.createInstance
                baseURL: baseURL

            client = lbPromised.createClient('leaves',
                belongsTo:
                    notebooks: 1
                accessToken: 'abc'
                debug: debug
                isUserModel: true # ignored
            )

            expect(client).to.be.instanceof LoopBackRelatedClient
            expect(client).to.have.property 'id', 1
            expect(client).to.have.property 'accessToken', 'abc'
            expect(client).to.have.property 'debug', debug
            expect(client).to.have.property 'pluralModelName', 'notebooks'
            expect(client).to.have.property 'pluralModelNameMany', 'leaves'


        it 'creates user client when "isUserModel" option is set', ->

            lbPromised = LoopBackPromised.createInstance
                baseURL: baseURL

            client = lbPromised.createClient('leaves',
                isUserModel: true
                accessToken: 'abc'
                debug: debug
            )

            expect(client).to.be.instanceof LoopBackUserClient
            expect(client).to.have.property 'accessToken', 'abc'
            expect(client).to.have.property 'debug', debug
            expect(client).to.have.property 'pluralModelName', 'leaves'



    describe 'createUserClient', ->

        it 'creates user client for one model', ->

            lbPromised = LoopBackPromised.createInstance
                baseURL: baseURL

            pluralModelName = 'authors'

            clientInfo      =
                accessToken: null
                debug: debug

            client = lbPromised.createUserClient(pluralModelName, clientInfo)

            expect(client).to.be.instanceof LoopBackClient
            expect(client).to.be.instanceof LoopBackUserClient


