

Promise = require('es6-promise').Promise


###*
LoopBack Client to access to PersistedModel (or extenders)

see http://docs.strongloop.com/display/public/LB/PersistedModel+REST+API
see also http://apidocs.strongloop.com/loopback/#persistedmodel

@class LoopBackClient
@module loopback-promised
###
class LoopBackClient

    ###*

    @constructor
    @param {LoopBackPromised} lbPromised
    @param {String} pluralModelName
    @param {String} [accessToken] Access Token
    @param {Boolean} [debug] shows debug log if true

    ###
    constructor: (@lbPromised, @pluralModelName, @accessToken, @debug) ->


    ###*
    sets Access Token

    @method setAccessToken
    @param {String} [accessToken] Access Token
    @return {Promise(Object)}
    ###
    setAccessToken: (@accessToken) ->


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

        @lbPromised.request(@pluralModelName, path, params, http_method, @)


    ###*
    Return the number of records that match the optional "where" filter.

    @method count
    @param {Object} [where]
    @return {Promise(Number)}
    ###
    count: (where = {}) ->

        path        = '/count'
        http_method = 'GET'

        params = {}
        params.where = where if Object.keys where

        @request(path, params, http_method)


    ###*
    Create new instance of Model class, saved in database

    @method create
    @param {Object} data
    @return {Promise(Object)}
    ###
    create: (data = {}) ->

        # when array is given, creates each data
        if Array.isArray data 
            return Promise.all (@create(d) for d in data)

        path        = ''
        http_method = 'POST'

        params = data

        @request(path, params, http_method)


    ###*
    Update or insert a model instance
    The update will override any specified attributes in the request data object. It won’t remove  existing ones unless the value is set to null.

    @method upsert
    @param {Object} data
    @return {Promise(Object)}
    ###
    upsert: (data = {}) ->

        path        = ''
        http_method = 'PUT'

        params = data

        @request(path, params, http_method)


    ###*
    Check whether a model instance exists in database.

    @method exists
    @param {String} id
    @return {Promise(Object)}
    ###
    exists: (id) ->

        path        = "/#{id}/exists"
        http_method = 'GET'

        params = null

        @request(path, params, http_method)


    ###*
    Find object by ID.

    @method findById
    @param {String} id
    @return {Promise(Object)}
    ###
    findById: (id) ->

        path        = "/#{id}"
        http_method = 'GET'

        params = null

        @request(path, params, http_method)



    ###*
    Find all model instances that match filter specification.

    @method find
    @param {Object} filter
    @return {Promise(Array(Object))}
    ###
    find: (filter) ->
        if filter?.where
            where = removeUndefinedKey(filter.where)
            if not where
                filter.where = null

        if filter? and filter.where is null
            if @debug
                console.log """
                    returns empty array, as "where" is null.
                """
            return Promise.resolve []

        path        = ''
        http_method = 'GET'

        params = filter: filter

        @request(path, params, http_method)

    ###*
    Find one model instance that matches filter specification. Same as find, but limited to one result

    @method findOne
    @param {Object} filter
    @return {Promise(Object)}
    ###
    findOne: (filter) ->

        path        = '/findOne'
        http_method = 'GET'

        params = filter: filter

        @request(path, params, http_method).catch (err) ->
            if err.isLoopBackResponseError and err.code is 'MODEL_NOT_FOUND'
                return null
            else
                throw err


    ###*
    Destroy model instance with the specified ID.

    @method destroyById
    @param {String} id
    @return {Promise}
    ###
    destroyById: (id) ->

        path        = "/#{id}"
        http_method = 'DELETE'

        params = null

        @request(path, params, http_method)


    ###*
    Destroy model instance

    @method destroy
    @param {Object} data
    @return {Promise}
    ###
    destroy: (data) ->

        @destroyById data.id


    ###*
    Update set of attributes.

    @method updateAttributes
    @param {Object} data
    @return {Promise(Object)}
    ###
    updateAttributes: (id, data) ->

        path        = "/#{id}"
        http_method = 'PUT'

        params = data

        @request(path, params, http_method)


    ###*
    Update multiple instances that match the where clause

    @method updateAll
    @param {Object} where
    @param {Object} data
    @return {Promise}
    ###
    updateAll: (where, data) ->

        path        = "/update?where=#{JSON.stringify where}"
        http_method = 'POST'

        params = data

        @request(path, params, http_method)


# remove keys whose value is undefined
# except Date, Moment
removeUndefinedKey = (obj) ->

    return obj if typeof obj isnt 'object' or obj is null

    return obj.toISOString() if typeof obj?.toISOString is 'function' # Date, Moment

    keynum = 0
    deletedKeynum = 0
    for key, value of obj
        value = removeUndefinedKey value

        if value is undefined
            delete obj[key]
            deletedKeynum++
        keynum++

    if keynum is deletedKeynum
        return undefined

    else
        return obj




module.exports = LoopBackClient
