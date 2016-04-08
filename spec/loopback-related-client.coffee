
LoopbackPromised      = require '../src/loopback-promised'
LoopbackRelatedClient = require '../src/loopback-related-client'

before ->
    @timeout 5000
    require('./init')

debug = false

baseURL = 'localhost:4157/test-api'

lbPromised = LoopbackPromised.createInstance
    baseURL: baseURL


mainNotebook = null

createClient = (options = {}) ->
    return lbPromised.createRelatedClient
        one   : 'notebooks'
        many  : 'leaves'
        id    : mainNotebook.id
        debug : options.debug ? debug



describe 'LoopbackRelatedClient', ->

    before ->
        client = lbPromised.createClient('notebooks', debug: debug)
        client.create(name: 'Loopback Docs').then (notebook) ->
            mainNotebook = notebook



    describe 'setAccessToken', ->

        it 'sets access token', ->

            client = createClient()
            client.setAccessToken('abcde')
            assert client.accessToken is 'abcde'


    describe 'create', ->

        it 'creates an item', ->

            client = createClient()

            client.create(
                content: 'for each access for each matched ACL, score is calculated'
                createdAt: new Date()
            ).then (responseBody) ->

                assert responseBody.notebookId is mainNotebook.id
                assert responseBody.content?
                assert responseBody.createdAt?


        it 'creates items when array is given', ->

            client = createClient()

            client.create([
                { content: 'Supports relation'   }
                { content: 'Well documented'  }
                { content: 'Written in JavaScript'}
            ]).then (results) ->
                assert results instanceof Array
                assert results.length is 3
                assert result.content? for result in results


    describe 'count', ->

        it 'counts items', ->

            client = createClient()
            client.count().then (num) ->
                assert num is 4


        it 'counts items with condition', ->

            client = createClient()
            where =
                content: like: 'Supports'

            client.count(where).then (num) ->
                assert num is 1


        it 'counts no items when no matching items', ->

            client = createClient()

            where =
                content: 'CoffeeScript'

            client.count(where).then (num) ->
                assert num is 0


    describe 'upsert', ->

        newId = null


        it 'creates when not exists', ->

            client = createClient()
            client.upsert(content: 'boot script can be async', about: 'boot').then (responseBody) ->

                assert responseBody.id?
                assert responseBody.content?
                assert responseBody.about is 'boot'
                newId = responseBody.id


        it 'updates when id exists', ->

            client = createClient()
            client.upsert(id: newId, importance: 'important').then (responseBody) ->
                assert responseBody.id is newId
                assert responseBody.content?
                assert responseBody.about is 'boot'
                assert responseBody.importance is 'important'



    describe 'exists', ->


        existingId = null
        notExistingId = 'abcd'

        before ->
            client = createClient()
            client.find().then (responseBody) ->
                existingId = responseBody[0].id

        it 'returns false when not exists', ->

            client = createClient()
            client.exists(notExistingId).then (responseBody) ->
                assert responseBody.exists is false


        it 'returns true when exists', ->

            client = createClient()
            client.exists(existingId).then (responseBody) ->
                assert responseBody.exists is true


    describe 'findById', ->


        existingId = null
        notExistingId = 'abcd'

        before ->
            client = createClient()
            client.find().then (responseBody) ->
                existingId = responseBody[0].id

        it 'returns error when not exists', ->

            client = createClient()
            client.findById(notExistingId).then((responseBody) ->

                throw new Error('this must not be called')

            , (err) ->
                # FIXME the error is different from loopback-client
                assert err instanceof Error
                assert err.status is 404
                assert err.isLoopbackResponseError is true
            )


        it 'returns object when exists', ->

            client = createClient()
            client.findById(existingId).then (responseBody) ->
                assert responseBody.notebookId is mainNotebook.id


    describe 'find', ->


        it 'returns all models when filter is not set', ->

            client = createClient()
            client.find().then (responseBody) ->
                assert responseBody instanceof Array
                assert responseBody.length > 4


        it 'returns specific field(s) when fields filter is set', ->

            client = createClient()
            client.find(fields: 'content').then (responseBody) ->
                assert responseBody instanceof Array
                assert responseBody.length > 4
                for item in responseBody
                    assert Object.keys(item).length is 1
                    assert item.content?

        it 'can set limit', ->

            client = createClient()
            client.find(limit: 3).then (responseBody) ->
                assert responseBody instanceof Array
                assert responseBody.length is 3

        it 'can set skip', ->

            client = createClient()
            Promise.all([
                client.find(limit: 2)
                client.find(limit: 1, skip: 1)
            ]).then (results) ->
                assert results[0][1].content is results[1][0].content


        it 'can set order. default order is ASC', ->

            client = createClient()
            client.find(order: 'content').then (responseBody) ->

                assert responseBody instanceof Array

                prevContent = null

                for item in responseBody
                    if prevContent?
                        assert(item.content> prevContent) is true
                    prevContent = item.content



        it 'can set order DESC', ->

            client = createClient()
            client.find(order: 'content DESC').then (responseBody) ->

                assert responseBody instanceof Array

                prevContent = null

                for item in responseBody
                    if prevContent?
                        assert(item.content < prevContent) is true
                    prevContent = item.content


        it 'can set order ASC', ->

            client = createClient()
            client.find(order: 'content ASC').then (responseBody) ->

                assert responseBody instanceof Array

                prevContent = null

                for item in responseBody
                    if prevContent?
                        assert(item.content> prevContent) is true
                    prevContent = item.content



        it 'can set where (equals)', ->

            client = createClient()
            client.find(where: content: 'Well documented').then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 1

                assert responseBody[0].content is 'Well documented'



        it 'can set where (or)', ->

            client = createClient()
            client.find(order: 'content', where: or: [{content: 'Well documented'}, {content: 'Written in JavaScript'}]).then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 2

                assert responseBody[0].content is 'Well documented'
                assert responseBody[1].content is 'Written in JavaScript'


        it 'can set where (implicit "and")', ->
            client = createClient()
            client.find(where: content: 'boot script can be async', about: 'boot').then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 1

                assert responseBody[0].about is 'boot'


        it 'can set where (explicit "and")', ->
            client = createClient()
            client.find(where: and: [{content: 'boot script can be async'}, {about: 'boot'}]).then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 1

                assert responseBody[0].about is 'boot'



        it 'can set where (greater than, less than)', ->
            client = createClient()
            client.find(order: 'content', where: and: [{content: gt: 'We'}, {content: lt: 'a'}]).then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 2

                assert responseBody[0].content is 'Well documented'
                assert responseBody[1].content is 'Written in JavaScript'


        it 'can set where (like) (not all data source support this request)', ->
            client = createClient()
            client.find(order: 'content', where: content : like: "[Ss]cript").then (responseBody) ->

                assert responseBody instanceof Array
                assert responseBody.length is 2

                assert responseBody[0].content is 'Written in JavaScript'
                assert responseBody[1].content is 'boot script can be async'


    describe 'findOne', ->


        it 'can get one result', ->

            client = createClient()

            client.findOne(order: 'content', where: content : like: "[Ss]cript").then (responseBody) ->

                assert responseBody.content is 'Written in JavaScript'

        it 'get null when not match', ->

            client = createClient()

            client.findOne(order: 'content', where: content : like: "xxxxx").then (responseBody) ->

                assert not responseBody?



    describe 'destroyById', ->


        idToDestroy = null
        wrongId     = 'abcde'

        before ->
            client = createClient()
            client.create(content: 'xxxxx').then (leaf) ->
                idToDestroy = leaf.id

        # FIXME: this behavior is different from LoopbackClient (this one is more intuitive)
        it 'returns 404 if id is wrong', ->

            client = createClient()
            client.destroyById(wrongId).then((responseBody) ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.status is 404
                assert err.isLoopbackResponseError is true
            )


        # FIXME: this behavior is different from LoopbackClient (this one is more intuitive)
        it 'destroys a model with id', ->

            client = createClient()
            client.destroyById(idToDestroy).then (responseBody) ->
                assert Object.keys(responseBody).length is 0

                client.exists(idToDestroy).then (responseBody) ->
                    assert responseBody.exists is false



    describe 'updateAttributes', ->

        existingId = null
        notExistingId = 'abcd'

        before ->
            client = createClient()
            client.findOne(where: content: like: 'JavaScript').then (notebook) ->
                existingId = notebook.id


        it 'returns error when id is invalid', ->

            data = version: 2

            client = createClient()
            client.updateAttributes(notExistingId, data).then((responseBody) ->
                throw new Error('this must not be called')

            , (err) ->
                assert err instanceof Error
                assert err.status is 404
                assert err.isLoopbackResponseError is true
            )


        it 'returns updated model when id is valid', ->

            data = version: 2

            client = createClient()
            client.updateAttributes(existingId, data).then (responseBody) ->
                assert responseBody.id is existingId
                assert responseBody.content is 'Written in JavaScript'
                assert responseBody.version is 2


    describe 'updateAll', ->

        it 'updates all matched models', ->

            where =
                content: like: '[Ss]cript'

            data =
                isAboutProgramming: true
                isAboutScript: true


            # FIXME: this behavior is different from LoopbackClient (this one is more intuitive)
            client = createClient()
            client.updateAll(where, data).then (results) ->

                assert results instanceof Array
                assert results.length is 2
                assert results[0].content is 'Written in JavaScript'
                assert results[1].content is 'boot script can be async'
                for result in results
                    assert result.isAboutProgramming is true
                    assert result.isAboutScript is true


    after ->
        client = lbPromised.createClient('notebooks', debug: debug)
        client.destroyById(mainNotebook.id).then ->


