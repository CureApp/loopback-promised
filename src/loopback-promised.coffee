
LoopBackClient        = require('./loopback-client')
LoopBackUserClient    = require('./loopback-user-client')
LoopBackRelatedClient = require('./loopback-related-client')

Promise = require('es6-promise').Promise
superagent = require('superagent')

DebugLogger = require('./util/debug-logger')

###*
LoopBackPromised

@class LoopBackPromised
@module loopback-promised
###

class LoopBackPromised

    ###*
    creates an instance

    @static
    @method createInstance
    @param {LoopBackPromised|Object} lbPromisedInfo
    @param {String} lbPromisedInfo.baseURL base URL of LoopBack
    @param {Object} [lbPromisedInfo.logger] logger with info(), warn(), error(), trace().
    @param {String} [lbPromisedInfo.version] version of LoopBack API to access
    @return {LoopBackPromised}
    ###
    @createInstance: (lbPromisedInfo = {}) ->

        new LoopBackPromised(
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
    sends request to LoopBack

    @method request
    @param {String} pluralModelName
    @param {String} path
    @param {Object} params request parameters
    @param {String} http_method {GET|POST|PUT|DELETE|HEAD}
    @param {LoopBackClient|Object} [clientInfo]
    @param {String}  [clientInfo.accessToken] Access Token
    @param {Boolean} [clientInfo.debug] shows debug log if true
    @return {Promise<Object>}
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
    @param {LoopBackClient|Object} [clientInfo]
    @param {String}  [clientInfo.accessToken] Access Token
    @param {Boolean} [clientInfo.debug] shows debug log if true
    @param {LoopBackPromised|Object}  lbPromisedInfo
    @param {String} lbPromisedInfo.baseURL base URL of LoopBack
    @param {String} [lbPromisedInfo.version] version of LoopBack API to access
    @param {Object} [lbPromisedInfo.logger] logger with info(), warn(), error(), trace().

    @return {Promise<Object>}
    ###
    @requestStatic: (endpoint, params = {}, http_method, clientInfo = {}, lbPromisedInfo) ->

        { accessToken, debug } = clientInfo

        { baseURL, logger, version } = lbPromisedInfo

        if debug
            debugLogger = new DebugLogger(endpoint, params, http_method, clientInfo, lbPromisedInfo)


        agentMethod = @agentMethodMap[http_method]

        unless baseURL
            return Promise.reject('baseURL is required.')

        unless agentMethod?
            return Promise.reject(new Error("no agent method for http_method:  #{http_method}"))


        if debug
            debugLogger.showRequestInfo()


        return new Promise (resolve, reject) ->
            url = if version?
                baseURL + '/' + version + endpoint
            else 
                baseURL + endpoint

            req = superagent[agentMethod](url)

            req.set('Authorization', accessToken) if accessToken

            if agentMethod is 'get'
                flattenParams = {}
                for k, v of params
                    continue if typeof v is 'function'
                    flattenParams[k] = if typeof v is 'object' then JSON.stringify(v) else v

                req.query(flattenParams)

            else if Object.keys(params).length
                req.send(JSON.stringify(params))
                req.set('Content-Type', 'application/json')

            req.set('Accept-Encoding', 'gzip')

            req.end (err, res) ->

                if err
                    if debug
                        debugLogger.showErrorInfo(err)

                    reject err
                    return


                try
                    if res.statusCode is 204 # No Contents
                        responseBody = {}
                    else
                        responseBody = JSON.parse(res.text)
                catch e
                    responseBody = error: res.text

                if debug
                    debugLogger.showResponseInfo(responseBody, res)


                if responseBody.error

                    if typeof responseBody.error is 'object'
                        err = new Error()
                        err[k] = v for k, v of responseBody.error
                        err.isLoopBackResponseError = true
                    else
                        err = new Error(responseBody.error)
                        # err.isLoopBackResponseError = true

                    return reject(err)

                else
                    return resolve(responseBody)


    ###*
    creates client for LoopBack

    @method createClient
    @param {String} pluralModelName
    @param {Object} [clientInfo]
    @param {String}  [clientInfo.accessToken] Access Token
    @param {Boolean} [clientInfo.debug] shows debug log if true
    @return {LoopBackClient}
    ###
    createClient: (pluralModelName, clientInfo = {}) ->
        new LoopBackClient(
            @
            pluralModelName
            clientInfo.accessToken
            clientInfo.debug
        )

    ###*
    creates user client for LoopBack

    @method createUserClient
    @param {String} pluralModelName
    @param {Object} [clientInfo]
    @param {String}  [clientInfo.accessToken] Access Token
    @param {Boolean} [clientInfo.debug] shows debug log if true
    @return {LoopBackClient}
    ###
    createUserClient: (pluralModelName, clientInfo = {}) ->
        new LoopBackUserClient(
            @
            pluralModelName
            clientInfo.accessToken
            clientInfo.debug
        )


    ###*
    creates related client (one-to-many relation)

    @method createRelatedClient
    @param {String} pluralModelNameOne the "one" side plural model of one-to-many relationship
    @param {String} pluralModelNameMany the "many" side plural model of one-to-many relationship
    @param {any} id the id of the "one" model
    @param {Object} [clientInfo]
    @param {String}  [clientInfo.accessToken] Access Token
    @param {Boolean} [clientInfo.debug] shows debug log if true
    @return {LoopBackClient}
    ###
    createRelatedClient: (pluralModelNameOne, pluralModelNameMany, id, clientInfo = {}) ->
        new LoopBackRelatedClient(
            @
            pluralModelNameOne
            pluralModelNameMany
            id
            clientInfo.accessToken
            clientInfo.debug
        )



    ###*
    HTTP methods => superagent methods

    @private
    @static
    @property agentMethodMap
    @type {Object}
    ###
    @agentMethodMap:
        DELETE : 'del'
        PUT    : 'put'
        GET    : 'get'
        POST   : 'post'
        HEAD   : 'head'

module.exports = LoopBackPromised
