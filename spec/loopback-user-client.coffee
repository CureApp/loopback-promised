
Promise = require('es6-promise').Promise

LoopBackPromised   = require '../src/loopback-promised'
LoopBackClient     = require '../src/loopback-client'
LoopBackUserClient = require '../src/loopback-user-client'

appServer = require('./init')

debug = false

baseURL = 'localhost:4157/test-api'

lbPromised = LoopBackPromised.createInstance
    baseURL: baseURL


idOfShin = null
accessTokenOfShin = null

idOfSatake = null

describe 'LoopBackUserClient', ->

    describe 'create', ->

        it 'cannot create without credential information (email/password)', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.create(firstName: 'Shin', lastName: 'Suzuki').then (responseBody) ->

                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'ValidationError'
                expect(err).to.have.property 'statusCode', 422
                done()


        it 'creates a user', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.create(firstName: 'Shin', lastName: 'Suzuki', email: 'shinout310@gmail.com', password: 'daikon123').then (responseBody) ->


                expect(responseBody).to.have.property 'firstName', 'Shin'
                expect(responseBody).to.have.property 'lastName', 'Suzuki'
                expect(responseBody).to.have.property 'email', 'shinout310@gmail.com'
                expect(responseBody).to.have.property 'id'
                expect(responseBody).not.to.have.property 'password'

                idOfShin = responseBody.id

                done()



    describe 'login', ->

        it 'fails with invalid credential (email/password)', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.login(email: 'shinout310@gmail.com', password: 'daikon121').then (responseBody) ->
                done new Error('this must not be called')

            .catch (err) ->

                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'LOGIN_FAILED'
                done()


        it 'returns an access token', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.login(email: 'shinout310@gmail.com', password: 'daikon123').then (responseBody) ->

                expect(responseBody).to.have.property 'id'
                expect(responseBody).to.have.property 'ttl'
                expect(responseBody).to.have.property 'userId'
                accessTokenOfShin = responseBody.id
                done()


        it 'returns an access token with user information when "include" is set', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.login(email: 'shinout310@gmail.com', password: 'daikon123', "user").then (responseBody) ->

                expect(responseBody).to.have.property 'id'
                expect(responseBody).to.have.property 'userId'
                expect(responseBody).to.have.property 'user'
                expect(responseBody.user).to.have.property 'id', responseBody.userId
                expect(responseBody.user).to.have.property 'email', 'shinout310@gmail.com'
                expect(responseBody.user).to.have.property 'firstName', 'Shin'
                done()


    describe 'create', ->

        it 'creates another user with accessToken', (done) ->
            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.create(firstName: 'Kohta', lastName: 'Satake', email: 'satake@example.com', password: 'satake111').then (responseBody) ->

                expect(responseBody).to.have.property 'firstName', 'Kohta'
                expect(responseBody).to.have.property 'lastName', 'Satake'
                expect(responseBody).to.have.property 'email', 'satake@example.com'
                expect(responseBody).to.have.property 'id'
                expect(responseBody).not.to.have.property 'password'

                idOfSatake = responseBody.id

                done()


    describe 'logout', ->

        client = lbPromised.createUserClient 'authors', debug: debug

        validAccessToken = null

        before (done) ->
            client.login(email: 'shinout310@gmail.com', password: 'daikon123').then (responseBody) ->
                validAccessToken = responseBody.id
                done()


        it 'returns error when an invalid access token is given', (done) ->

            invalidAccessToken = 'abcd'

            client.logout(invalidAccessToken).then (responseBody) ->

                done new Error('this must not be called')

            .catch (err) ->

                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'status', 500

                done()


        it 'returns {} when valid access token is given', (done) ->

            client.logout(validAccessToken).then (responseBody) ->

                expect(Object.keys(responseBody)).to.have.length 0

                #TODO confirm the token is deleted

                done()



    describe 'upsert', ->

        it 'requires authorization', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            params =
                firstName: 'Kohta'
                lastName : 'Satake'
                email    : 'satake@example.com'
                password : 'satake123'

            client.upsert(params).then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


        it 'requires authorization even if the user exists', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            params =
                id       : idOfShin
                firstName: 'Kohta'

            client.upsert(params).then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


        it 'fails even when given id is the token\'s user id', (done) ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            params =
                id       : idOfShin
                nationality: 'Japan'

            authedClient.upsert(params).then (responseBody) ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()



    describe 'count', ->

        it 'requires authorization', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.count().then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


        it 'fails even when user token is set', (done) ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.count().then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


    describe 'find', ->

        it 'requires authorization', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.find().then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


        it 'fails even when user token is set', (done) ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.find().then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


    describe 'findOne', ->

        it 'requires authorization', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.findOne().then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


        it 'fails even when user token is set', (done) ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.findOne().then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()



    describe 'findById', ->

        it 'requires authorization', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.findById(idOfShin).then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


        it 'returns user when given id is the token\'s user id', (done) ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.findById(idOfShin).then (responseBody) ->

                expect(responseBody).to.have.property 'id', idOfShin
                expect(responseBody).to.have.property 'firstName', 'Shin'

                done()

        it 'fails when given id is not the token\'s user id', (done) ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.findById(idOfSatake).then (responseBody) ->

                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


    describe 'exists', ->

        it 'requires authorization', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.exists(1).then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


        it 'fails even when given id is the token\'s user id', (done) ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.exists(idOfShin).then (responseBody) ->

                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()

    describe 'updateAttributes', ->

        it 'requires authorization', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.updateAttributes(1, firstName: 'Shinji').then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


        it 'updates user when given id is the token\'s user id', (done) ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            data = hobby: 'music'

            authedClient.updateAttributes(idOfShin, data).then (responseBody) ->

                expect(responseBody).to.have.property 'id', idOfShin
                expect(responseBody).to.have.property 'firstName', 'Shin'
                expect(responseBody).to.have.property 'hobby', 'music'

                done()


        it 'fails when given id is not the token\'s user id', (done) ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.updateAttributes(idOfSatake, hobby: 'music').then (responseBody) ->

                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


    describe 'updateAll', ->

        it 'requires authorization', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.updateAll({firstName: 'Shin'}, {lastName: 'Sasaki'}).then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


        it 'fails even when condition includes the token\'s user', (done) ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            data = profession: 'doctor'

            authedClient.updateAll(id: idOfShin, data).then (responseBody) ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()


    describe 'destroyById', ->

        it 'requires authorization', (done) ->

            client = lbPromised.createUserClient 'authors', debug: debug

            client.destroyById(1).then ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()



        it 'fails when given id is not the token\'s user id', (done) ->

            authedClient = lbPromised.createUserClient 'authors', debug: debug, accessToken: accessTokenOfShin

            authedClient.destroyById(idOfSatake).then (responseBody) ->

                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'name', 'Error'
                expect(err).to.have.property 'statusCode', 401
                expect(err).to.have.property 'code', 'AUTHORIZATION_REQUIRED'
                done()

        it 'deletes user when given id is the token\'s user id', (done) ->

            authedClient = lbPromised.createUserClient 'authors', debug: false, accessToken: accessTokenOfShin

            authedClient.destroyById(idOfShin).then (responseBody) ->

                expect(Object.keys(responseBody)).to.have.length 0

                done()
