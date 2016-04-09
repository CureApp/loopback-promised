
LoopbackPromised      = require '../src/loopback-promised'
LoopbackClient        = require '../src/loopback-client'
LoopbackUserClient    = require '../src/loopback-user-client'
LoopbackRelatedClient = require '../src/loopback-related-client'
PushManager           = require '../src/push-manager'

before ->
    @timeout 5000
    require('./init')

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

            lbPromised.request(pluralModelName, path, params, http_method, clientInfo).then((responseBody) ->

                throw new Error('this cannot occur')

            , (e) ->
                assert e.match /baseURL/ # TODO: should return error
            )


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

            lbPromised.request(pluralModelName, path, params, http_method, clientInfo).then((responseBody) ->
                throw new Error('this cannot occur')
            , (e) ->
                assert e.code is 'ECONNREFUSED'
            )

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

            lbPromised.request(pluralModelName, path, params, http_method, clientInfo).then((responseBody) ->
                throw new Error('this cannot occur')
            , (e) ->
                assert e.message.match /Cannot GET/
            )


        it 'requests to the server', ->

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
                assert responseBody instanceof Array

        it 'timeouts when timeout msec is given and exceeds', ->

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
                assert e.message.match /timeout/


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

            assert client instanceof LoopbackClient
            assert client.timeout is 8000


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

            assert client instanceof LoopbackRelatedClient
            assert client.id is 1
            assert client.accessToken is 'abc'
            assert client.debug is debug
            assert client.pluralModelName is 'notebooks'
            assert client.pluralModelNameMany is 'leaves'
            assert client.timeout is 8000


        it 'creates user client when "isUserModel" option is set', ->

            lbPromised = LoopbackPromised.createInstance
                baseURL: baseURL

            client = lbPromised.createClient('leaves',
                isUserModel: true
                accessToken: 'abc'
                timeout: 8000
                debug: debug
            )

            assert client instanceof LoopbackUserClient
            assert client.accessToken is 'abc'
            assert client.debug is debug
            assert client.pluralModelName is 'leaves'
            assert client.timeout is 8000



    describe 'createUserClient', ->

        it 'creates user client for one model', ->

            lbPromised = LoopbackPromised.createInstance
                baseURL: baseURL

            pluralModelName = 'authors'

            clientInfo      =
                accessToken: null
                debug: debug

            client = lbPromised.createUserClient(pluralModelName, clientInfo)

            assert client instanceof LoopbackClient
            assert client instanceof LoopbackUserClient

    describe 'createPushManager', ->

        it 'creates push notification manager', ->

            lbPromised = LoopbackPromised.createInstance
                baseURL: baseURL

            clientInfo =
                accessToken: null
                debug: debug

            client = lbPromised.createPushManager(clientInfo)

            assert client instanceof PushManager


    describe '@isDebugMode', ->

        before ->
            @LBP_DEBUG = process.env.LBP_DEBUG

        after ->
            process.env.LBP_DEBUG = @LBP_DEBUG

        it 'returns true when given param is true', ->

            assert LoopbackPromised.isDebugMode(true) is true

        it 'returns true when given param is false but process.env.LBP_DEBUG exists', ->

            process.env.LBP_DEBUG = '1'

            assert LoopbackPromised.isDebugMode(false) is true

        it 'returns false when given param is false and process.env.LBP_DEBUG does not exist', ->

            delete process.env.LBP_DEBUG

            assert LoopbackPromised.isDebugMode(false) is false

