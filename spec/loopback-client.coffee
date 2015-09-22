
Promise = require('es6-promise').Promise

LoopbackPromised   = require '../src/loopback-promised'
LoopbackClient     = require '../src/loopback-client'
LoopbackUserClient = require '../src/loopback-user-client'

before (done) ->
    @timeout 5000
    require('./init').then -> done()


debug = true

baseURL = 'localhost:4157/test-api'

lbPromised = LoopbackPromised.createInstance
    baseURL: baseURL

describe 'LoopbackClient', ->


    describe 'setAccessToken', ->

        it 'sets access token', ->

            client = lbPromised.createClient 'notebooks', debug: debug

            client.setAccessToken('abcde')

            expect(client.accessToken).to.equal 'abcde'



    describe 'create', ->

        it 'creates an item', (done) ->

            client = lbPromised.createClient 'notebooks', debug: debug

            client.create(
                name: 'Computer Science'
                options:
                    version: 2
                    references: ['The Elements of Statistical Learning']
            ).then (responseBody) ->

                expect(responseBody).to.have.property 'name', 'Computer Science'
                expect(responseBody).to.have.property 'options'
                expect(responseBody.options).to.have.property 'version', 2
                expect(responseBody.options.references).to.have.length 1
                done()

        it 'creates items when array is given', (done) ->

            client = lbPromised.createClient 'notebooks', debug: debug

            client.create([
                { name: 'Physics'   }
                { name: 'Japanese'  }
                { name: 'JavaScript'}
            ]).then (results) ->
                expect(results).to.be.instanceof Array
                expect(results).to.have.length 3
                expect(result).to.have.property 'name' for result in results
                done()
            .catch (e) ->
                done e

    describe 'count', ->

        it 'counts items', (done) ->

            client = lbPromised.createClient 'notebooks', debug: debug
            client.count().then (num) ->
                expect(num).to.equal 4
                done()


        it 'counts items with condition', (done) ->

            client = lbPromised.createClient 'notebooks', debug: debug

            where =
                name: 'Computer Science'

            client.count(where).then (num) ->
                expect(num).to.equal 1
                done()


        it 'counts no items when no matching items', (done) ->

            client = lbPromised.createClient 'notebooks', debug: debug

            where =
                name: 'Philosophy'

            client.count(where).then (num) ->
                expect(num).to.equal 0
                done()



    describe 'upsert', ->

        newId = null

        client = lbPromised.createClient 'notebooks', debug: debug

        it 'creates when not exists', (done) ->

            client.upsert(name: 'Genetics', genre: 'Biology').then (responseBody) ->
                expect(responseBody).to.have.property 'id'
                expect(responseBody).to.have.property 'name', 'Genetics'
                expect(responseBody).to.have.property 'genre', 'Biology'
                newId = responseBody.id
                done()

        it 'updates when id exists', (done) ->

            client.upsert(id: newId, name: 'BioGenetics', difficulty: 'difficult').then (responseBody) ->
                expect(responseBody).to.have.property 'id', newId
                expect(responseBody).to.have.property 'name', 'BioGenetics'
                expect(responseBody).to.have.property 'genre', 'Biology'
                expect(responseBody).to.have.property 'difficulty', 'difficult'
                done()



    describe 'exists', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        existingId = null
        notExistingId = 'abcd'

        before (done) ->
            client.findOne(where: name: 'JavaScript').then (notebook) ->
                existingId = notebook.id
                done()

        it 'returns false when not exists', (done) ->

            client.exists(notExistingId).then (responseBody) ->
                expect(responseBody).to.have.property 'exists', false
                done()


        it 'returns true when exists', (done) ->

            client.exists(existingId).then (responseBody) ->
                expect(responseBody).to.have.property 'exists', true
                done()



    describe 'findById', ->

        existingId = null
        notExistingId = 'abcd'

        beforeEach (done) ->
            @client = lbPromised.createClient 'notebooks', debug: debug

            @client.findOne(where: name: 'JavaScript').then (notebook) ->
                existingId = notebook.id
                done()

        it 'returns error when not exists', (done) ->

            @client.findById(notExistingId).then (responseBody) ->

                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'code', 'MODEL_NOT_FOUND'
                expect(err).to.have.property 'isLoopbackResponseError', true
                done()


        it 'returns object when exists', (done) ->

            @client.findById(existingId).then (responseBody) ->
                expect(responseBody).to.have.property 'name', 'JavaScript'
                done()

        it 'timeouts when timeout property is given and exceeds', (done) ->

            @client.timeout = 1

            @client.findById(existingId).catch (e) ->
                expect(e).to.match /timeout/
                done()


    describe 'find', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        it 'returns all models when filter is not set', (done) ->

            client.find().then (responseBody) ->
                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length.above 4
                done()


        it 'returns specific field(s) when fields filter is set', (done) ->

            client.find(fields: 'name').then (responseBody) ->
                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length.above 4
                for item in responseBody
                    expect(Object.keys(item).length).to.equal 1
                    expect(item).to.have.property 'name'
                done()


        it 'can set limit', (done) ->

            client.find(limit: 3).then (responseBody) ->
                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 3
                done()

        it 'can set skip', (done) ->

            Promise.all([
                client.find(limit: 2)
                client.find(limit: 1, skip: 1)
            ]).then (results) ->
                expect(results[0][1].name).to.equal results[1][0].name
                done()


        it 'can set order. default order is ASC', (done) ->

            client.find(order: 'name').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array

                prevName = null

                for item in responseBody
                    if prevName?
                        expect(item.name > prevName).to.be.true
                    prevName = item.name
                done()

        it 'can set order DESC', (done) ->

            client.find(order: 'name DESC').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array

                prevName = null

                for item in responseBody
                    if prevName?
                        expect(item.name < prevName).to.be.true
                    prevName = item.name
                done()

        it 'can set order ASC', (done) ->
            client.find(order: 'name ASC').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array

                prevName = null

                for item in responseBody
                    if prevName?
                        expect(item.name > prevName).to.be.true
                    prevName = item.name

                done()

        it 'can set where (null)', (done) ->

            client.find(where: null).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 0
                done()


        it 'can set where (equals)', (done) ->
            client.find(where: name: 'Physics').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 1

                expect(responseBody[0].name).to.equal 'Physics'
                done()


        it 'can set where (or)', (done) ->
            client.find(order: 'name', where: or: [{name: 'Physics'}, {name: 'BioGenetics'}]).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 2

                expect(responseBody[0].name).to.equal 'BioGenetics'
                expect(responseBody[1].name).to.equal 'Physics'
                done()


        it 'can set where (key: null)', (done) ->
            client.find(where: difficulty: null).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 4
                done()

        it 'can set where (key: undefined)', (done) ->
            client.find(where: difficulty: undefined).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 0
                done()



        it 'can set where (implicit "and")', (done) ->
            client.find(order: 'name', where: name: 'BioGenetics', difficulty: 'difficult').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 1

                expect(responseBody[0].name).to.equal 'BioGenetics'
                done()


        it 'can set where (explicit "and")', (done) ->
            client.find(order: 'name', where: and: [{name: 'BioGenetics'}, {difficulty: 'difficult'}]).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 1

                expect(responseBody[0].name).to.equal 'BioGenetics'
                done()



        it 'can set where (greater than, less than)', (done) ->
            client.find(order: 'name', where: and: [{name: gt: 'Ja'}, {name: lt: 'K'}]).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 2

                expect(responseBody[0].name).to.equal 'Japanese'
                expect(responseBody[1].name).to.equal 'JavaScript'
                done()


        it 'can set where (like)', (done) ->
            client.find(order: 'name', where: name: like: "ic").then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 2

                expect(responseBody[0].name).to.equal 'BioGenetics'
                expect(responseBody[1].name).to.equal 'Physics'
                done()


    describe 'findOne', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        it 'can get one result', (done) ->

            client.findOne(order: 'name', where: name: like: "ic").then (responseBody) ->

                expect(responseBody.name).to.equal 'BioGenetics'
                done()


        it 'gets null when not match', (done) ->

            client.findOne(order: 'name', where: name: like: "xxx").then (responseBody) ->

                expect(responseBody).not.to.exist
                done()


    describe 'destroyById', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        idToDestroy = null
        wrongId     = 'abcde'

        before (done) ->
            client.create(name: 'xxxxx').then (notebook) ->
                idToDestroy = notebook.id
                done()

        # TODO: this is the spec of Loopback (they always return 204). We should take this into account or change the API
        it 'returns 204 even if id is wrong', (done) ->

            client.destroyById(wrongId).then (responseBody) ->
                expect(Object.keys(responseBody)).to.have.length 0
                done()


        it 'destroys a model with id', (done) ->
            client.destroyById(idToDestroy).then (responseBody) ->
                expect(Object.keys(responseBody)).to.have.length 0

                client.exists(idToDestroy).then (responseBody) ->
                    expect(responseBody.exists).to.be.false
                    done()



    describe 'destroy', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        modelToDestroy = null

        before (done) ->
            client.create(name: 'xxxxx').then (notebook) ->
                modelToDestroy = notebook
                done()

        it 'destroys a model', (done) ->
            client.destroy(modelToDestroy).then (responseBody) ->
                expect(Object.keys(responseBody)).to.have.length 0

                client.exists(modelToDestroy.id).then (responseBody) ->
                    expect(responseBody.exists).to.be.false
                    done()



    describe 'updateAttributes', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        existingId = null
        notExistingId = 'abcd'

        before (done) ->
            client.findOne(where: name: 'JavaScript').then (notebook) ->
                existingId = notebook.id
                done()


        it 'returns error when id is invalid', (done) ->

            data = version: 2

            client.updateAttributes(notExistingId, data).then (responseBody) ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'code', 'MODEL_NOT_FOUND'
                expect(err).to.have.property 'isLoopbackResponseError', true
                done()


        it 'returns updated model when id is valid', (done) ->

            data = version: 2

            client.updateAttributes(existingId, data).then (responseBody) ->
                expect(responseBody).to.have.property 'id', existingId
                expect(responseBody).to.have.property 'name', 'JavaScript'
                expect(responseBody).to.have.property 'version', 2
                done()


    describe 'updateAll', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        it 'updates all matched models', (done) ->

            where =
                name: like: 'ic'

            data =
                isAcademic:   true
                isScientific: true

            # TODO: this is the spec of Loopback (they return 204). We should take this into account or change the API
            client.updateAll(where, data).then (responseBody) ->
                expect(Object.keys(responseBody)).to.have.length 0

                client.find(order: 'name', where: {isAcademic: true, isScientific: true}).then (results) ->

                    expect(results).to.be.instanceof Array
                    expect(results).to.have.length 2
                    expect(results[0]).to.have.property 'name', 'BioGenetics'
                    expect(results[1]).to.have.property 'name', 'Physics'
                    done()



