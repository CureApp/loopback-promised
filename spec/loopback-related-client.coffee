
Promise = require('es6-promise').Promise

LoopbackPromised      = require '../src/loopback-promised'
LoopbackRelatedClient = require '../src/loopback-related-client'

before (done) ->
    @timeout 5000
    require('./init').then -> done()

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

    before (done) ->
        client = lbPromised.createClient('notebooks', debug: debug)
        client.create(name: 'Loopback Docs').then (notebook) ->
            mainNotebook = notebook
            done()



    describe 'setAccessToken', ->

        it 'sets access token', ->

            client = createClient()
            client.setAccessToken('abcde')
            expect(client.accessToken).to.equal 'abcde'


    describe 'create', ->

        it 'creates an item', (done) ->

            client = createClient()

            client.create(
                content: 'for each access for each matched ACL, score is calculated'
                createdAt: new Date()
            ).then (responseBody) ->

                expect(responseBody).to.have.property 'notebookId', mainNotebook.id
                expect(responseBody).to.have.property 'content'
                expect(responseBody).to.have.property 'createdAt'

                console.log responseBody
                done()

        it 'creates items when array is given', (done) ->

            client = createClient()

            client.create([
                { content: 'Supports relation'   }
                { content: 'Well documented'  }
                { content: 'Written in JavaScript'}
            ]).then (results) ->
                expect(results).to.be.instanceof Array
                expect(results).to.have.length 3
                expect(result).to.have.property 'content' for result in results
                done()
            .catch (e) ->
                done e


    describe 'count', ->

        it 'counts items', (done) ->

            client = createClient()
            client.count().then (responseBody) ->
                expect(responseBody).to.have.property 'count', 4
                done()


        it 'counts items with condition', (done) ->

            client = createClient()
            where =
                content: like: 'Supports'

            client.count(where).then (responseBody) ->
                expect(responseBody).to.have.property 'count', 1
                done()


        it 'counts no items when no matching items', (done) ->

            client = createClient()

            where =
                content: 'CoffeeScript'

            client.count(where).then (responseBody) ->
                expect(responseBody).to.have.property 'count', 0
                done()


    describe 'upsert', ->

        newId = null


        it 'creates when not exists', (done) ->

            client = createClient()
            client.upsert(content: 'boot script can be async', about: 'boot').then (responseBody) ->

                expect(responseBody).to.have.property 'id'
                expect(responseBody).to.have.property 'content'
                expect(responseBody).to.have.property 'about', 'boot'
                newId = responseBody.id
                done()

        it 'updates when id exists', (done) ->

            client = createClient()
            client.upsert(id: newId, importance: 'important').then (responseBody) ->
                expect(responseBody).to.have.property 'id', newId
                expect(responseBody).to.have.property 'content'
                expect(responseBody).to.have.property 'about', 'boot'
                expect(responseBody).to.have.property 'importance', 'important'
                done()



    describe 'exists', ->


        existingId = null
        notExistingId = 'abcd'

        before (done) ->
            client = createClient()
            client.find().then (responseBody) ->
                existingId = responseBody[0].id
                done()

        it 'returns false when not exists', (done) ->

            client = createClient()
            client.exists(notExistingId).then (responseBody) ->
                expect(responseBody).to.have.property 'exists', false
                done()


        it 'returns true when exists', (done) ->

            client = createClient()
            client.exists(existingId).then (responseBody) ->
                expect(responseBody).to.have.property 'exists', true
                done()


    describe 'findById', ->


        existingId = null
        notExistingId = 'abcd'

        before (done) ->
            client = createClient()
            client.find().then (responseBody) ->
                existingId = responseBody[0].id
                done()

        it 'returns error when not exists', (done) ->

            client = createClient()
            client.findById(notExistingId).then (responseBody) ->

                done new Error('this must not be called')

            .catch (err) ->
                # FIXME the error is different from loopback-client
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'status', 404
                expect(err).to.have.property 'isLoopbackResponseError', true
                done()


        it 'returns object when exists', (done) ->

            client = createClient()
            client.findById(existingId).then (responseBody) ->
                expect(responseBody).to.have.property 'notebookId', mainNotebook.id
                done()


    describe 'find', ->


        it 'returns all models when filter is not set', (done) ->

            client = createClient()
            client.find().then (responseBody) ->
                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length.above 4
                done()


        it 'returns specific field(s) when fields filter is set', (done) ->

            client = createClient()
            client.find(fields: 'content').then (responseBody) ->
                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length.above 4
                for item in responseBody
                    expect(Object.keys(item).length).to.equal 1
                    expect(item).to.have.property 'content'
                done()

        it 'can set limit', (done) ->

            client = createClient()
            client.find(limit: 3).then (responseBody) ->
                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 3
                done()

        it 'can set skip', (done) ->

            client = createClient()
            Promise.all([
                client.find(limit: 2)
                client.find(limit: 1, skip: 1)
            ]).then (results) ->
                expect(results[0][1].content).to.equal results[1][0].content
                done()


        it 'can set order. default order is ASC', (done) ->

            client = createClient()
            client.find(order: 'content').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array

                prevContent = null

                for item in responseBody
                    if prevContent?
                        expect(item.content> prevContent).to.be.true
                    prevContent = item.content
                done()



        it 'can set order DESC', (done) ->

            client = createClient()
            client.find(order: 'content DESC').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array

                prevContent = null

                for item in responseBody
                    if prevContent?
                        expect(item.content < prevContent).to.be.true
                    prevContent = item.content
                done()


        it 'can set order ASC', (done) ->

            client = createClient()
            client.find(order: 'content ASC').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array

                prevContent = null

                for item in responseBody
                    if prevContent?
                        expect(item.content> prevContent).to.be.true
                    prevContent = item.content
                done()



        it 'can set where (equals)', (done) ->

            client = createClient()
            client.find(where: content: 'Well documented').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 1

                expect(responseBody[0].content).to.equal 'Well documented'
                done()



        it 'can set where (or)', (done) ->

            client = createClient()
            client.find(order: 'content', where: or: [{content: 'Well documented'}, {content: 'Written in JavaScript'}]).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 2

                expect(responseBody[0].content).to.equal 'Well documented'
                expect(responseBody[1].content).to.equal 'Written in JavaScript'
                done()


        it 'can set where (implicit "and")', (done) ->
            client = createClient()
            client.find(where: content: 'boot script can be async', about: 'boot').then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 1

                expect(responseBody[0].about).to.equal 'boot'
                done()


        it 'can set where (explicit "and")', (done) ->
            client = createClient()
            client.find(where: and: [{content: 'boot script can be async'}, {about: 'boot'}]).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 1

                expect(responseBody[0].about).to.equal 'boot'
                done()



        it 'can set where (greater than, less than)', (done) ->
            client = createClient()
            client.find(order: 'content', where: and: [{content: gt: 'We'}, {content: lt: 'a'}]).then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 2

                expect(responseBody[0].content).to.equal 'Well documented'
                expect(responseBody[1].content).to.equal 'Written in JavaScript'
                done()


        it 'can set where (like) (not all data source support this request)', (done) ->
            client = createClient()
            client.find(order: 'content', where: content : like: "[Ss]cript").then (responseBody) ->

                expect(responseBody).to.be.instanceof Array
                expect(responseBody).to.have.length 2

                expect(responseBody[0].content).to.equal 'Written in JavaScript'
                expect(responseBody[1].content).to.equal 'boot script can be async'
                done()


    describe 'findOne', ->


        it 'can get one result', (done) ->

            client = createClient()

            client.findOne(order: 'content', where: content : like: "[Ss]cript").then (responseBody) ->

                expect(responseBody.content).to.equal 'Written in JavaScript'
                done()

        it 'get null when not match', (done) ->

            client = createClient()

            client.findOne(order: 'content', where: content : like: "xxxxx").then (responseBody) ->

                expect(responseBody).not.to.exist
                done()



    describe 'destroyById', ->


        idToDestroy = null
        wrongId     = 'abcde'

        before (done) ->
            client = createClient()
            client.create(content: 'xxxxx').then (leaf) ->
                idToDestroy = leaf.id
                done()

        # FIXME: this behavior is different from LoopbackClient (this one is more intuitive)
        it 'returns 404 if id is wrong', (done) ->

            client = createClient()
            client.destroyById(wrongId).then (responseBody) ->
                done new Error('this must not be called')
            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'status', 404
                expect(err).to.have.property 'isLoopbackResponseError', true
                done()


        # FIXME: this behavior is different from LoopbackClient (this one is more intuitive)
        it 'destroys a model with id', (done) ->

            client = createClient()
            client.destroyById(idToDestroy).then (responseBody) ->
                expect(Object.keys(responseBody)).to.have.length 0

                client.exists(idToDestroy).then (responseBody) ->
                    expect(responseBody.exists).to.be.false
                    done()



    describe 'updateAttributes', ->

        existingId = null
        notExistingId = 'abcd'

        before (done) ->
            client = createClient()
            client.findOne(where: content: like: 'JavaScript').then (notebook) ->
                existingId = notebook.id
                done()


        it 'returns error when id is invalid', (done) ->

            data = version: 2

            client = createClient()
            client.updateAttributes(notExistingId, data).then (responseBody) ->
                done new Error('this must not be called')

            .catch (err) ->
                expect(err).to.be.instanceof Error
                expect(err).to.have.property 'status', 404
                expect(err).to.have.property 'isLoopbackResponseError', true
                done()


        it 'returns updated model when id is valid', (done) ->

            data = version: 2

            client = createClient()
            client.updateAttributes(existingId, data).then (responseBody) ->
                expect(responseBody).to.have.property 'id', existingId
                expect(responseBody).to.have.property 'content', 'Written in JavaScript'
                expect(responseBody).to.have.property 'version', 2
                done()


    describe 'updateAll', ->

        it 'updates all matched models', (done) ->

            where =
                content: like: '[Ss]cript'

            data =
                isAboutProgramming: true
                isAboutScript: true


            # FIXME: this behavior is different from LoopbackClient (this one is more intuitive)
            client = createClient()
            client.updateAll(where, data).then (results) ->

                expect(results).to.be.instanceof Array
                expect(results).to.have.length 2
                expect(results[0]).to.have.property 'content', 'Written in JavaScript'
                expect(results[1]).to.have.property 'content', 'boot script can be async'
                for result in results
                    expect(result).to.have.property 'isAboutProgramming', true
                    expect(result).to.have.property 'isAboutScript', true
                done()


    after (done) ->
        client = lbPromised.createClient('notebooks', debug: debug)
        client.destroyById(mainNotebook.id).then ->
            done()


