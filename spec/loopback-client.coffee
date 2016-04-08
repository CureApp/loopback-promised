
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

            assert client.accessToken is 'abcde'



    describe 'create', ->

        it 'creates an item', ->

            client = lbPromised.createClient 'notebooks', debug: debug

            client.create(
                name: 'Computer Science'
                options:
                    version: 2
                    references: ['The Elements of Statistical Learning']
            ).then (responseBody) ->

                assert responseBody.name is 'Computer Science'
                assert responseBody.options?
                assert responseBody.options.version is 2
                assert responseBody.options.references.length is 1

        it 'creates items when array is given', ->

            client = lbPromised.createClient 'notebooks', debug: debug

            client.create([
                { name: 'Physics'   }
                { name: 'Japanese'  }
                { name: 'JavaScript'}
            ]).then (results) ->
                assert results instanceof Array
                assert results.length is 3
                assert result.name? for result in results

    describe 'count', ->

        it 'counts items', ->

            client = lbPromised.createClient 'notebooks', debug: debug
            client.count().then (num) ->
                assert num is 4


        it 'counts items with condition', ->

            client = lbPromised.createClient 'notebooks', debug: debug

            where =
                name: 'Computer Science'

            client.count(where).then (num) ->
                assert num is 1


        it 'counts no items when no matching items', ->

            client = lbPromised.createClient 'notebooks', debug: debug

            where =
                name: 'Philosophy'

            client.count(where).then (num) ->
                assert num is 0



    describe 'upsert', ->

        newId = null

        client = lbPromised.createClient 'notebooks', debug: debug

        it 'creates when not exists', ->

            client.upsert(name: 'Genetics', genre: 'Biology').then (responseBody) ->
                assert responseBody.id?
                assert responseBody.name is 'Genetics'
                assert responseBody.genre is 'Biology'
                newId = responseBody.id

        it 'updates when id exists', ->

            client.upsert(id: newId, name: 'BioGenetics', difficulty: 'difficult').then (responseBody) ->
                assert responseBody.id is newId
                assert responseBody.name is 'BioGenetics'
                assert responseBody.genre is 'Biology'
                assert responseBody.difficulty is 'difficult'



    describe 'exists', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        existingId = null
        notExistingId = 'abcd'

        before ->
            client.findOne(where: name: 'JavaScript').then (notebook) ->
                existingId = notebook.id

        it 'returns false when not exists', ->

            client.exists(notExistingId).then (responseBody) ->
                assert responseBody.exists is false


        it 'returns true when exists', ->

            client.exists(existingId).then (responseBody) ->
                assert responseBody.exists is true



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
                assert err instanceof Error
                assert err.code is 'MODEL_NOT_FOUND'
                assert err.isLoopbackResponseError is true
            )


        it 'returns object when exists', ->

            @client.findById(existingId).then (responseBody) ->
                assert responseBody.name is 'JavaScript'


        it 'timeouts when timeout property is given and exceeds', ->

            @client.timeout = 1

            @client.findById(existingId).catch (e) ->
                assert e.message.match /timeout/


    describe 'find', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        it 'returns all models when filter is not set', ->

            client.find().then (responseBody) ->
                assert responseBody instanceof Array
                assert responseBody.length > 4


        it 'returns specific field(s) when fields filter is set', ->

            client.find(fields: 'name').then (responseBody) ->
                assert responseBody instanceof Array
                assert responseBody.length > 4
                for item in responseBody
                    assert Object.keys(item).length is 1
                    assert item.name?


        it 'can set limit', ->

            client.find(limit: 3).then (responseBody) ->
                assert responseBody instanceof Array
                assert responseBody.length is 3

        it 'can set skip', ->

            Promise.all([
                client.find(limit: 2)
                client.find(limit: 1, skip: 1)
            ]).then (results) ->
                assert results[0][1].name is results[1][0].name


        it 'can set order. default order is ASC', ->

            client.find(order: 'name').then (responseBody) ->

                assert responseBody instanceof Array

                prevName = null

                for item in responseBody
                    if prevName?
                        assert (item.name > prevName) is true
                    prevName = item.name

        it 'can set order DESC',  ->

            client.find(order: 'name DESC').then (responseBody) ->

                assert responseBody instanceof Array

                prevName = null

                for item in responseBody
                    if prevName?
                        assert (item.name < prevName) is true
                    prevName = item.name

        it 'can set order ASC', ->
            client.find(order: 'name ASC').then (responseBody) ->

                assert responseBody instanceof Array

                prevName = null

                for item in responseBody
                    if prevName?
                        assert (item.name > prevName) is true
                    prevName = item.name


        it 'can set where (null)', ->

            client.find(where: null).then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 0


        it 'can set where (equals)', ->
            client.find(where: name: 'Physics').then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 1

                assert responseBody[0].name is 'Physics'


        it 'can set where (or)', ->
            client.find(order: 'name', where: or: [{name: 'Physics'}, {name: 'BioGenetics'}]).then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 2

                assert responseBody[0].name is 'BioGenetics'
                assert responseBody[1].name is 'Physics'


        it 'can set where (key: null)', ->
            client.find(where: difficulty: null).then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 4

        it 'can set where (key: undefined)', ->
            client.find(where: difficulty: undefined).then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 0



        it 'can set where (implicit "and")', ->
            client.find(order: 'name', where: name: 'BioGenetics', difficulty: 'difficult').then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 1

                assert responseBody[0].name is 'BioGenetics'


        it 'can set where (explicit "and")', ->
            client.find(order: 'name', where: and: [{name: 'BioGenetics'}, {difficulty: 'difficult'}]).then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 1

                assert responseBody[0].name is 'BioGenetics'



        it 'can set where (greater than, less than)', ->
            client.find(order: 'name', where: and: [{name: gt: 'Ja'}, {name: lt: 'K'}]).then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 2

                assert responseBody[0].name is 'Japanese'
                assert responseBody[1].name is 'JavaScript'


        it 'can set where (like)', ->
            client.find(order: 'name', where: name: like: "ic").then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 2

                assert responseBody[0].name is 'BioGenetics'
                assert responseBody[1].name is 'Physics'


    describe 'findOne', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        it 'can get one result', ->

            client.findOne(order: 'name', where: name: like: "ic").then (responseBody) ->

                assert responseBody.name is 'BioGenetics'


        it 'gets null when not match', ->

            client.findOne(order: 'name', where: name: like: "xxx").then (responseBody) ->

                assert not responseBody?


    describe 'destroyById', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        idToDestroy = null
        wrongId     = 'abcde'

        before ->
            client.create(name: 'xxxxx').then (notebook) ->
                idToDestroy = notebook.id


        it 'returns 200 and count information is returned', ->

            client.destroyById(wrongId).then (responseBody) ->
                assert responseBody.count is 0


        it 'destroys a model with id', ->
            client.destroyById(idToDestroy).then (responseBody) ->

                assert responseBody.count is 1

                client.exists(idToDestroy).then (responseBody) ->
                    assert responseBody.exists is false



    describe 'destroy', ->

        client = lbPromised.createClient 'notebooks', debug: debug

        modelToDestroy = null

        before ->
            client.create(name: 'xxxxx').then (notebook) ->
                modelToDestroy = notebook

        it 'destroys a model', ->
            client.destroy(modelToDestroy).then (responseBody) ->
                assert responseBody.count is 1

                client.exists(modelToDestroy.id).then (responseBody) ->
                    assert responseBody.exists is false



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
                assert err instanceof Error
                assert err.code is 'MODEL_NOT_FOUND'
                assert err.isLoopbackResponseError is true
            )


        it 'returns updated model when id is valid', ->

            data = version: 2

            client.updateAttributes(existingId, data).then (responseBody) ->
                assert responseBody.id is existingId
                assert responseBody.name is 'JavaScript'
                assert responseBody.version is 2


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
                assert responseBody.count is 2

                client.find(order: 'name', where: {isAcademic: true, isScientific: true}).then (results) ->

                    assert results instanceof Array
                    assert results.length is 2
                    assert results[0].name is 'BioGenetics'
                    assert results[1].name is 'Physics'

