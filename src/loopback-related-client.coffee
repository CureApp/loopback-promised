
Promise = require('es6-promise').Promise
LoopBackClient = require('./loopback-client')


###*
LoopBack Client to access to PersistedModel (or extenders) via one-to-many relation

@class LoopBackRelatedClient
@extends LoopBackClient
@module loopback-promised
###
class LoopBackRelatedClient extends LoopBackClient

    ###*

    @constructor
    @param {LoopBackPromised} lbPromised
    @param {String} pluralModelName the "one" side plural model of one-to-many relationship
    @param {String} pluralModelNameMany the "many" side plural model of one-to-many relationship
    @param {any} id the id of the "one" model
    @param {String} [accessToken] Access Token
    @param {Boolean} [debug] shows debug log if true
    @return {LoopBackClient}
    ###
    constructor: (@lbPromised, @pluralModelName, @pluralModelNameMany, @id, @accessToken, @debug) ->

    ###*
    set id of the "one" model

    @method setAccessToken
    @param {any} id
    @return {Promise(Object)}
    ###
    setId: (@id) ->


    ###*
    sends request to LoopBack

    @method request
    @private
    @param {String} path
    @param {Object} params request parameters
    @param {String} http_method {GET|POST|PUT|DELETE}
    @return {Promise(Object)}
    ###
    request: (path, params = {}, http_method) ->

        path = "/#{@id}/#{@pluralModelNameMany}#{path}"

        @lbPromised.request(@pluralModelName, path, params, http_method, @)


    ###*
    Update or insert a model instance
    The update will override any specified attributes in the request data object. It won’t remove  existing ones unless the value is set to null.

    @method upsert
    @param {Object} data
    @return {Promise(Object)}
    ###
    upsert: (data = {}) ->

        if data.id?
            params = {}
            params[k] = v for k,v of data when k isnt 'id'
            @updateAttributes(data.id, params)
        else
            @create(data)


    ###*
    Check whether a model instance exists in database.

    @method exists
    @param {String} id
    @return {Promise(Object)}
    ###
    exists: (id) ->

        @findById(id).then (data) ->

            return exists: true

        .catch (err) ->

            if err.isLoopBackResponseError
                return exists: false

            throw err


    ###*
    Find one model instance that matches filter specification. Same as find, but limited to one result

    @method findOne
    @param {Object} filter
    @return {Promise(Object)}
    ###
    findOne: (filter) ->

        @find(filter).then (results) -> results[0]




    ###*
    Update multiple instances that match the where clause

    @method updateAll
    @param {Object} where
    @param {Object} data
    @return {Promise(Array(Object))}
    ###
    updateAll: (where, data) ->

        @find(where: where, fields: 'id').then (results) =>
            Promise.all (@updateAttributes(result.id, data) for result in results)




module.exports = LoopBackRelatedClient
