
LoopbackClient        = require('./loopback-client')
LoopbackUserClient    = require('./loopback-user-client')
LoopbackRelatedClient = require('./loopback-related-client')
PushManager           = require('./push-manager')

DebugLogger = require('./util/debug-logger')

fetch = require('fetch-ponyfill')()
qs = require 'qs'

timeoutLimit = (msec, promise) ->
    new Promise (resolve, reject) ->
        setTimeout ->
            reject(new Error("timeout of #{msec}ms exceeded"))
        , msec
        promise.then(resolve, reject)

###*
LoopbackPromised

@class LoopbackPromised
@module loopback-promised
###

class LoopbackPromised

    ###*
    creates an instance

    @static
    @method createInstance
    @param {LoopbackPromised|Object} lbPromisedInfo
    @param {String} lbPromisedInfo.baseURL base URL of Loopback
    @param {Object} [lbPromisedInfo.logger] logger with info(), warn(), error(), trace().
    @param {String} [lbPromisedInfo.version] version of Loopback API to access
    @return {LoopbackPromised}
    ###
    @createInstance: (lbPromisedInfo = {}) ->

        new LoopbackPromised(
            lbPromisedInfo.baseURL
            lbPromisedInfo.logger
            lbPromisedInfo.version
        )

    ###*

    @constructor
    @private
    ###
    constructor: (
        @baseURL
        @logger
        @version
    ) ->


    ###*
    sends request to Loopback

    @method request
    @param {String} pluralModelName
    @param {String} path
    @param {Object} params request parameters
    @param {String} http_method {GET|POST|PUT|DELETE|HEAD}
    @param {LoopbackClient|Object} [clientInfo]
    @param {String}  [clientInfo.accessToken] Access Token
    @param {Boolean} [clientInfo.debug] shows debug log if true
    @return {Promise(Object)}
    ###
    request: (pluralModelName, path, params = {}, http_method, clientInfo = {}) ->

        endpoint = "/#{pluralModelName}#{path}"

        @constructor.requestStatic(endpoint, params, http_method, clientInfo, @)




    ###*
    calls rest api directly

    @static
    @method requestStatic
    @param {String} endpoint
    @param {Object} [params]
    @param {String} http_method {GET|POST|PUT|DELETE|HEAD}
    @param {LoopbackClient|Object} [clientInfo]
    @param {String}  [clientInfo.accessToken] Access Token
    @param {Boolean} [clientInfo.debug] shows debug log if true
    @param {LoopbackPromised|Object}  lbPromisedInfo
    @param {String} lbPromisedInfo.baseURL base URL of Loopback
    @param {String} [lbPromisedInfo.version] version of Loopback API to access
    @param {Object} [lbPromisedInfo.logger] logger with info(), warn(), error(), trace().

    @return {Promise(Object)}
    ###
    @requestStatic: (endpoint, params = {}, http_method, clientInfo = {}, lbPromisedInfo) ->

        { accessToken, debug, timeout } = clientInfo

        { baseURL, logger, version } = lbPromisedInfo

        debug = @isDebugMode debug

        if debug
            debugLogger = new DebugLogger(endpoint, params, http_method, clientInfo, lbPromisedInfo)


        unless baseURL
            return Promise.reject('baseURL is required.')

        if baseURL.slice(0, 4) isnt 'http'
            baseURL = 'http://' + baseURL


        if debug
            debugLogger.showRequestInfo()

        url = if version?
            baseURL + '/' + version + endpoint
        else
            baseURL + endpoint

        fetchParams =
            method: http_method
            headers: {}
        fetchParams.headers.Authorization = accessToken if accessToken

        if http_method is 'GET'
            flattenParams = {}
            for k, v of params
                continue if typeof v is 'function'
                flattenParams[k] = if typeof v is 'object' then JSON.stringify(v) else v

            queryString = qs.stringify(flattenParams)
            url += '?' + queryString if queryString

        else if Object.keys(params).length
            fetchParams.body = JSON.stringify(params)
            fetchParams.headers['Content-Type'] = 'application/json'

        responseStatus = null

        fetched = fetch(url, fetchParams).then (response) ->
            responseStatus = response.status
            if responseStatus is 204 # No Contents
                return '{}'
            else
                return response.text()

        , (err) ->
            if debug
                debugLogger.showErrorInfo(err)
            throw err

        .then (text) ->
            try
                responseBody = JSON.parse(text)
            catch e
                responseBody = error: text

            if debug
                debugLogger.showResponseInfo(responseBody, responseStatus)

            if responseBody.error

                if typeof responseBody.error is 'object'
                    err = new Error()
                    err[k] = v for k, v of responseBody.error
                    err.isLoopbackResponseError = true
                else
                    err = new Error(responseBody.error)
                    # err.isLoopbackResponseError = true
                throw err
            else
                return responseBody

        return if timeout? then timeoutLimit(timeout, fetched) else fetched

    ###*
    creates client for Loopback

    @method createClient
    @param {String} pluralModelName
    @param {Object}  [options]
    @param {Object}  [options.belongsTo] key: pluralModelName (the "one" side of one-to-many relation), value: id
    @param {Boolean} [options.isUserModel] true if user model
    @param {String}  [options.accessToken] Access Token
    @param {Boolean} [options.debug] shows debug log if true
    @return {LoopbackClient}
    ###
    createClient: (pluralModelName, options = {}) ->

        if options.belongsTo
            pluralModelNameOne = Object.keys(options.belongsTo)[0]
            id = options.belongsTo[pluralModelNameOne]

            return @createRelatedClient
                one         : pluralModelNameOne
                many        : pluralModelName
                id          : id
                timeout     : options.timeout
                accessToken : options.accessToken
                debug       : options.debug

        else if options.isUserModel
            return @createUserClient(pluralModelName, options)

        new LoopbackClient(
            @
            pluralModelName
            options.accessToken
            options.timeout
            options.debug
        )

    ###*
    creates user client for Loopback

    @method createUserClient
    @param {String} pluralModelName
    @param {Object} [clientInfo]
    @param {String}  [clientInfo.accessToken] Access Token
    @param {Boolean} [clientInfo.debug] shows debug log if true
    @return {LoopbackClient}
    ###
    createUserClient: (pluralModelName, clientInfo = {}) ->
        new LoopbackUserClient(
            @
            pluralModelName
            clientInfo.accessToken
            clientInfo.timeout
            clientInfo.debug
        )


    ###*
    creates related client (one-to-many relation)

    @method createRelatedClient
    @param {Object} options
    @param {String} options.one the "one" side plural model of one-to-many relationship
    @param {String} options.many the "many" side plural model of one-to-many relationship
    @param {any} options.id the id of the "one" model
    @param {String}  [options.accessToken] Access Token
    @param {Boolean} [options.debug] shows debug log if true
    @return {LoopbackClient}
    ###
    createRelatedClient: (options) ->
        new LoopbackRelatedClient(
            @
            options.one
            options.many
            options.id
            options.accessToken
            options.timeout
            options.debug
        )

    ###*
    creates push manager

    @method createPushManager
    @public
    @param {Object} [clientInfo]
    @param {String}  [clientInfo.accessToken] Access Token
    @param {Boolean} [clientInfo.debug] shows debug log if true
    @return {PushManager}
    ###
    createPushManager: (clientInfo = {}) ->
        new PushManager(
            @
            clientInfo.accessToken
            clientInfo.debug
        )

    ###*
    check environment variable concerning debug

    @private
    @static
    @method isDebugMode
    @param {Boolean} debug
    @return {Boolean} shows debug log or not
    ###
    @isDebugMode: (debug) ->

        return debug or !!process?.env?.LBP_DEBUG


LoopbackPromised.Promise               = Promise
LoopbackPromised.LoopbackClient        = LoopbackClient
LoopbackPromised.LoopbackUserClient    = LoopbackUserClient
LoopbackPromised.LoopbackRelatedClient = LoopbackRelatedClient

module.exports = LoopbackPromised
