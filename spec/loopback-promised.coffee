
LoopbackPromised      = require '../src/loopback-promised'
LoopbackClient        = require '../src/loopback-client'
LoopbackUserClient    = require '../src/loopback-user-client'
LoopbackRelatedClient = require '../src/loopback-related-client'
PushManager           = require '../src/push-manager'

before (done) ->
    @timeout 5000
    require('./init').then -> done()

debug = false


baseURL = 'localhost:4157/test-api'

describe 'LoopbackPromised', ->


    describe 'request', ->

        it 'cannot request to the server when baseURL is not set', ->

            lbPromised = LoopbackPromised.createInstance()

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

            lbPromised = LoopbackPromised.createInstance
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

            lbPromised = LoopbackPromised.createInstance
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

            lbPromised = LoopbackPromised.createInstance
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

        it 'timeouts when timeout msec is given and exceeds', (done) ->

            lbPromised = LoopbackPromised.createInstance
                baseURL: baseURL

            pluralModelName = 'notebooks'
            path            = ''
            params          = null
            http_method     = 'GET'
            clientInfo      =
                accessToken: null
                debug: debug
                timeout: 1

            lbPromised.request(pluralModelName, path, params, http_method, clientInfo).catch (e) ->
                expect(e.message).to.match /timeout/
                done()


    describe 'createClient', ->

        it 'creates client for one model', ->

            lbPromised = LoopbackPromised.createInstance
                baseURL: baseURL

            pluralModelName = 'notebooks'

            clientInfo      =
                accessToken: null
                timeout: 8000
                debug: debug

            client = lbPromised.createClient(pluralModelName, clientInfo)

            expect(client).to.be.instanceof LoopbackClient
            expect(client).to.have.property 'timeout', 8000


        it 'creates related client when "belongsTo" option is set', ->

            lbPromised = LoopbackPromised.createInstance
                baseURL: baseURL

            client = lbPromised.createClient('leaves',
                belongsTo:
                    notebooks: 1
                accessToken: 'abc'
                timeout: 8000
                debug: debug
                isUserModel: true # ignored
            )

            expect(client).to.be.instanceof LoopbackRelatedClient
            expect(client).to.have.property 'id', 1
            expect(client).to.have.property 'accessToken', 'abc'
            expect(client).to.have.property 'debug', debug
            expect(client).to.have.property 'pluralModelName', 'notebooks'
            expect(client).to.have.property 'pluralModelNameMany', 'leaves'
            expect(client).to.have.property 'timeout', 8000


        it 'creates user client when "isUserModel" option is set', ->

            lbPromised = LoopbackPromised.createInstance
                baseURL: baseURL

            client = lbPromised.createClient('leaves',
                isUserModel: true
                accessToken: 'abc'
                timeout: 8000
                debug: debug
            )

            expect(client).to.be.instanceof LoopbackUserClient
            expect(client).to.have.property 'accessToken', 'abc'
            expect(client).to.have.property 'debug', debug
            expect(client).to.have.property 'pluralModelName', 'leaves'
            expect(client).to.have.property 'timeout', 8000



    describe 'createUserClient', ->

        it 'creates user client for one model', ->

            lbPromised = LoopbackPromised.createInstance
                baseURL: baseURL

            pluralModelName = 'authors'

            clientInfo      =
                accessToken: null
                debug: debug

            client = lbPromised.createUserClient(pluralModelName, clientInfo)

            expect(client).to.be.instanceof LoopbackClient
            expect(client).to.be.instanceof LoopbackUserClient

    describe 'createPushManager', ->

        it 'creates push notification manager', ->

            lbPromised = LoopbackPromised.createInstance
                baseURL: baseURL

            clientInfo =
                accessToken: null
                debug: debug

            client = lbPromised.createPushManager(clientInfo)

            expect(client).to.be.instanceof PushManager


    describe '@isDebugMode', ->

        before ->
            @LBP_DEBUG = process.env.LBP_DEBUG

        after ->
            process.env.LBP_DEBUG = @LBP_DEBUG

        it 'returns true when given param is true', ->

            expect(LoopbackPromised.isDebugMode(true)).to.be.true

        it 'returns true when given param is false but process.env.LBP_DEBUG exists', ->

            process.env.LBP_DEBUG = '1'

            expect(LoopbackPromised.isDebugMode(false)).to.be.true

        it 'returns false when given param is false and process.env.LBP_DEBUG does not exist', ->

            delete process.env.LBP_DEBUG

            expect(LoopbackPromised.isDebugMode(false)).to.be.false

