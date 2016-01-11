
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

describe 'LoopbackClient', ->


    describe 'setAccessToken', ->

        it 'sets access token', ->

            client = lbPromised.createClient 'notebooks', debug: debug

            client.setAccessToken('abcde')

            expect(client.accessToken).to.equal 'abcde'



    describe 'create', ->

        it 'creates an item', ->

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

        it 'creates items when array is given', ->

            client = lbPromised.createClient 'notebooks', debug: debug

            client.create([
                { name: 'Physics'   }
                { name: 'Japanese'  }
                { name: 'JavaScript'}
            ]).then (results) ->
                expect(results).to.be.instanceof Array
                expect(results).to.have.length 3
                expect(result).to.have.property 'name' for result in results

    describe 'count', ->

        it 'counts items', ->

            client = lbPromised.createClient 'notebooks', debug: debug
            client.count().then (num) ->
                expect(num).to.equal 4


        it 'counts items with condition', ->

            client = lbPromised.createClient 'notebooks', debug: debug

            where =
                name: 'Computer Science'

            client.count(where).then (num) ->
                expect(num).to.equal 1


        it 'counts no items when no matching items', ->

            client = lbPromised.createClient 'notebooks', debug: debug

            where =
                name: 'Philosophy'

            client.count(where).then (num) ->
                expect(num).to.equal 0



    describe 'upsert', ->

        newId = null

        client = lbPromised.createClient 'notebooks', debug: debug

        it 'creates when not exists', ->

            client.upsert(name: 'Genetics', genre: 'Biology').then (responseBody) ->
                expect(responseBody).to.have.property 'id'
                expect(responseBody).to.have.property 'name', 'Genetics'
                expect(responseBody).to.have.property 'genre', 'Biology'
                newId = responseBody.id

        it 'updates when id exists', ->

            client.upsert(id: newId, name: 'BioGenetics', difficulty: 'difficult').then (responseBody) ->
                expect(responseBody).to.have.property 'id', newId
                expect(responseBody).to.have.property 'name', 'BioGenetics'
                expect(responseBody).to.have.property 'genre', 'Biology'
                expect(responseBody).to.have.property 'difficulty', 'difficult'



    describe 'exists', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        existingId = null
        notExistingId = 'abcd'

        before ->
            client.findOne(where: name: 'JavaScript').then (notebook) ->
                existingId = notebook.id

        it 'returns false when not exists', ->

            client.exists(notExistingId).then (responseBody) ->
                expect(responseBody).to.have.property 'exists', false


        it 'returns true when exists', ->

            client.exists(existingId).then (responseBody) ->
                expect(responseBody).to.have.property 'exists', true



    describe 'findById', ->

        existingId = null
        notExistingId = 'abcd'

        beforeEach ->
            @client = lbPromised.createClient 'notebooks', debug: debug

            @client.findOne(where: name: 'JavaScript').then (notebook) ->
                existingId = notebook.id

        it 'returns error when not exists', ->

            @client.findById(notExistingId).then((responseBody) ->

                throw new Error('this must not be called')

            , (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'code', 'MODEL_NOT_FOUND'
                expect(err).to.have.property 'isLoopbackResponseError', true
            )


        it 'returns object when exists', ->

            @client.findById(existingId).then (responseBody) ->
                expect(responseBody).to.have.property 'name', 'JavaScript'


        it 'timeouts when timeout property is given and exceeds', ->

            @client.timeout = 1

            @client.findById(existingId).catch (e) ->
                expect(e).to.match /timeout/


    describe 'find', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        it 'returns all models when filter is not set', ->

            client.find().then (responseBody) ->
                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length.above 4


        it 'returns specific field(s) when fields filter is set', ->

            client.find(fields: 'name').then (responseBody) ->
                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length.above 4
                for item in responseBody
                    expect(Object.keys(item).length).to.equal 1
                    expect(item).to.have.property 'name'


        it 'can set limit', ->

            client.find(limit: 3).then (responseBody) ->
                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 3

        it 'can set skip', ->

            Promise.all([
                client.find(limit: 2)
                client.find(limit: 1, skip: 1)
            ]).then (results) ->
                expect(results[0][1].name).to.equal results[1][0].name


        it 'can set order. default order is ASC', ->

            client.find(order: 'name').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array

                prevName = null

                for item in responseBody
                    if prevName?
                        expect(item.name > prevName).to.be.true
                    prevName = item.name

        it 'can set order DESC',  ->

            client.find(order: 'name DESC').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array

                prevName = null

                for item in responseBody
                    if prevName?
                        expect(item.name < prevName).to.be.true
                    prevName = item.name

        it 'can set order ASC', ->
            client.find(order: 'name ASC').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array

                prevName = null

                for item in responseBody
                    if prevName?
                        expect(item.name > prevName).to.be.true
                    prevName = item.name


        it 'can set where (null)', ->

            client.find(where: null).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 0


        it 'can set where (equals)', ->
            client.find(where: name: 'Physics').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 1

                expect(responseBody[0].name).to.equal 'Physics'


        it 'can set where (or)', ->
            client.find(order: 'name', where: or: [{name: 'Physics'}, {name: 'BioGenetics'}]).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 2

                expect(responseBody[0].name).to.equal 'BioGenetics'
                expect(responseBody[1].name).to.equal 'Physics'


        it 'can set where (key: null)', ->
            client.find(where: difficulty: null).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 4

        it 'can set where (key: undefined)', ->
            client.find(where: difficulty: undefined).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 0



        it 'can set where (implicit "and")', ->
            client.find(order: 'name', where: name: 'BioGenetics', difficulty: 'difficult').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 1

                expect(responseBody[0].name).to.equal 'BioGenetics'


        it 'can set where (explicit "and")', ->
            client.find(order: 'name', where: and: [{name: 'BioGenetics'}, {difficulty: 'difficult'}]).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 1

                expect(responseBody[0].name).to.equal 'BioGenetics'



        it 'can set where (greater than, less than)', ->
            client.find(order: 'name', where: and: [{name: gt: 'Ja'}, {name: lt: 'K'}]).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 2

                expect(responseBody[0].name).to.equal 'Japanese'
                expect(responseBody[1].name).to.equal 'JavaScript'


        it 'can set where (like)', ->
            client.find(order: 'name', where: name: like: "ic").then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 2

                expect(responseBody[0].name).to.equal 'BioGenetics'
                expect(responseBody[1].name).to.equal 'Physics'


    describe 'findOne', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        it 'can get one result', ->

            client.findOne(order: 'name', where: name: like: "ic").then (responseBody) ->

                expect(responseBody.name).to.equal 'BioGenetics'


        it 'gets null when not match', ->

            client.findOne(order: 'name', where: name: like: "xxx").then (responseBody) ->

                expect(responseBody).not.to.exist


    describe 'destroyById', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        idToDestroy = null
        wrongId     = 'abcde'

        before ->
            client.create(name: 'xxxxx').then (notebook) ->
                idToDestroy = notebook.id

        # TODO: this is the spec of Loopback (they always return 204). We should take this into account or change the API
        it 'returns 204 even if id is wrong', ->

            client.destroyById(wrongId).then (responseBody) ->
                expect(Object.keys(responseBody)).to.have.length 0


        it 'destroys a model with id', ->
            client.destroyById(idToDestroy).then (responseBody) ->
                expect(Object.keys(responseBody)).to.have.length 0

                client.exists(idToDestroy).then (responseBody) ->
                    expect(responseBody.exists).to.be.false



    describe 'destroy', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        modelToDestroy = null

        before ->
            client.create(name: 'xxxxx').then (notebook) ->
                modelToDestroy = notebook

        it 'destroys a model', ->
            client.destroy(modelToDestroy).then (responseBody) ->
                expect(Object.keys(responseBody)).to.have.length 0

                client.exists(modelToDestroy.id).then (responseBody) ->
                    expect(responseBody.exists).to.be.false



    describe 'updateAttributes', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        existingId = null
        notExistingId = 'abcd'

        before ->
            client.findOne(where: name: 'JavaScript').then (notebook) ->
                existingId = notebook.id


        it 'returns error when id is invalid', ->

            data = version: 2

            client.updateAttributes(notExistingId, data).then((responseBody) ->
                throw new Error('this must not be called')

            , (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'code', 'MODEL_NOT_FOUND'
                expect(err).to.have.property 'isLoopbackResponseError', true
            )


        it 'returns updated model when id is valid', ->

            data = version: 2

            client.updateAttributes(existingId, data).then (responseBody) ->
                expect(responseBody).to.have.property 'id', existingId
                expect(responseBody).to.have.property 'name', 'JavaScript'
                expect(responseBody).to.have.property 'version', 2


    describe 'updateAll', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        it 'updates all matched models', ->

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

