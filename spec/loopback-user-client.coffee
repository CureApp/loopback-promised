
LoopbackPromised   = require '../src/loopback-promised'
LoopbackClient     = require '../src/loopback-client'
LoopbackUserClient = require '../src/loopback-user-client'

before ->
    @timeout 5000
    require('./init')

debug = true

baseURL = 'localhost:4157/test-api'

lbPromised = LoopbackPromised.createInstance
    baseURL: baseURL


idOfShin = null
accessTokenOfShin = null

idOfSatake = null

describe 'LoopbackUserClient', ->

    describe 'create', ->

        it 'cannot create without credential information (email/password)', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.create(firstName: 'Shin', lastName: 'Suzuki').then((responseBody) ->

                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'ValidationError'
                assert err.statusCode is 422
            )


        it 'creates a user', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.create(firstName: 'Shin', lastName: 'Suzuki', email: 'shinout310@gmail.com', password: 'daikon123').then (responseBody) ->


                assert responseBody.firstName is 'Shin'
                assert responseBody.lastName is 'Suzuki'
                assert responseBody.email is 'shinout310@gmail.com'
                assert responseBody.id?
                assert not responseBody.password?

                idOfShin = responseBody.id




    describe 'login', ->

        it 'fails with invalid credential (email/password)', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.login(email: 'shinout310@gmail.com', password: 'daikon121').then((responseBody) ->
                throw new Error('this must not be called')

            , (err) ->

                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'LOGIN_FAILED'
            )


        it 'returns an access token', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.login(email: 'shinout310@gmail.com', password: 'daikon123').then (responseBody) ->

                assert responseBody.id?
                assert responseBody.ttl?
                assert responseBody.userId?
                accessTokenOfShin = responseBody.id


        it 'returns an access token with user information when "include" is set', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.login(email: 'shinout310@gmail.com', password: 'daikon123', "user").then (responseBody) ->

                assert responseBody.id?
                assert responseBody.userId?
                assert responseBody.user?
                assert responseBody.user.id is responseBody.userId
                assert responseBody.user.email is 'shinout310@gmail.com'
                assert responseBody.user.firstName is 'Shin'


    describe 'create', ->

        it 'creates another user with accessToken', ->
            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.create(firstName: 'Kohta', lastName: 'Satake', email: 'satake@example.com', password: 'satake111').then (responseBody) ->

                assert responseBody.firstName is 'Kohta'
                assert responseBody.lastName is 'Satake'
                assert responseBody.email is 'satake@example.com'
                assert responseBody.id?
                assert not responseBody.password?

                idOfSatake = responseBody.id



    describe 'logout', ->

        client = lbPromised.createUserClient 'authors', debug: debug

        validAccessToken = null

        before ->
            client.login(email: 'shinout310@gmail.com', password: 'daikon123').then (responseBody) ->
                validAccessToken = responseBody.id


        it 'returns error when an invalid access token is given', ->

            invalidAccessToken = 'abcd'

            client.logout(invalidAccessToken).then((responseBody) ->

                throw new Error('this must not be called')

            , (err) ->

                assert err instanceof Error
                assert err.name is 'Error'
                assert err.status is 500
            )



        it 'returns {} when valid access token is given', ->

            client.logout(validAccessToken).then (responseBody) ->

                assert Object.keys(responseBody).length is 0

                #TODO confirm the token is deleted




    describe 'upsert', ->

        it 'requires authorization', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            params =
                firstName: 'Kohta'
                lastName : 'Satake'
                email    : 'satake@example.com'
                password : 'satake123'

            client.upsert(params).then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


        it 'requires authorization even if the user exists', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            params =
                id       : idOfShin
                firstName: 'Kohta'

            client.upsert(params).then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


        it 'fails even when given id is the token\'s user id', ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            params =
                id       : idOfShin
                nationality: 'Japan'

            authedClient.upsert(params).then((responseBody) ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )



    describe 'count', ->

        it 'requires authorization', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.count().then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


        it 'fails even when user token is set', ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.count().then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


    describe 'find', ->

        it 'requires authorization', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.find().then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


        it 'fails even when user token is set', ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.find().then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


    describe 'findOne', ->

        it 'requires authorization', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.findOne().then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


        it 'fails even when user token is set', ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.findOne().then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )



    describe 'findById', ->

        it 'requires authorization', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.findById(idOfShin).then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


        it 'returns user when given id is the token\'s user id', ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.findById(idOfShin).then (responseBody) ->

                assert responseBody.id is idOfShin
                assert responseBody.firstName is 'Shin'


        it 'fails when given id is not the token\'s user id', ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.findById(idOfSatake).then((responseBody) ->

                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


    describe 'exists', ->

        it 'requires authorization', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.exists(1).then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


        it 'fails even when given id is the token\'s user id', ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.exists(idOfShin).then((responseBody) ->

                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )

    describe 'updateAttributes', ->

        it 'requires authorization', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.updateAttributes(1, firstName: 'Shinji').then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


        it 'updates user when given id is the token\'s user id', ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            data = hobby: 'music'

            authedClient.updateAttributes(idOfShin, data).then (responseBody) ->

                assert responseBody.id is idOfShin
                assert responseBody.firstName is 'Shin'
                assert responseBody.hobby is 'music'


        it 'fails when given id is not the token\'s user id', ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.updateAttributes(idOfSatake, hobby: 'music').then((responseBody) ->

                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


    describe 'updateAll', ->

        it 'requires authorization', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.updateAll({firstName: 'Shin'}, {lastName: 'Sasaki'}).then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


        it 'fails even when condition includes the token\'s user', ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            data = profession: 'doctor'

            authedClient.updateAll(id: idOfShin, data).then((responseBody) ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )


    describe 'destroyById', ->

        it 'requires authorization', ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.destroyById(1).then( ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )



        it 'fails when given id is not the token\'s user id', ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.destroyById(idOfSatake).then((responseBody) ->

                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.name is 'Error'
                assert err.statusCode is 401
                assert err.code is 'AUTHORIZATION_REQUIRED'
            )

        it 'deletes user when given id is the token\'s user id', ->

            authedClient = lbPromised.createUserClient 'authors', debug: false, accessToken: accessTokenOfShin

            authedClient.destroyById(idOfShin).then (responseBody) ->

                assert responseBody.count is 1
