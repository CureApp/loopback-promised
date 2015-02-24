
LoopBackClient = require('./loopback-client')
Promise = require('es6-promise').Promise
superagent = require('superagent')
c = require('./util/color')

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
    @param {Object}  lbPromisedInfo
    @param {String}  lbPromisedInfo.baseURL base URL of LoopBack
    @param {Object}  [lbPromisedInfo.logger] logger with info(), warn(), error(), trace().
    @param {String}  [lbPromisedInfo.version] version of LoopBack API to access
    @return {LoopBackPromised}
    ###
    @createInstance : (lbPromisedInfo) ->

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

        @logger ?= @constructor.getLogger()
        @logger.now ?= -> new Date()




    ###*
    sends request to LoopBack

    @method request
    @param {String} modelName
    @param {String} path
    @param {Object} params request parameters
    @param {String} http_method {GET|POST|PUT|DELETE|HEAD}
    @param {LoopBackClient|Object} [clientInfo]
    @param {String}  [clientInfo.accessToken] Access Token
    @param {Boolean} [clientInfo.debug] shows debug log if true
    @return {Promise<Object>}
    ###
    request: (modelName, path, params = {}, http_method, clientInfo = {}) ->

        endpoint = "/#{modelName}#{path}"

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

        logger ?= @getLogger()

        agentMethod = @agentMethodMap[http_method]

        unless agentMethod?
            return Promise.reject(new Error("no agent method for http_method:  #{http_method}"))

        if debug

            logger.info "\n"
            logger.info "┏────────────────────────────────────────────────────────────────────────────────"
            logger.info "┃ #{if logger.now? then logger.now() else new Date()}"
            logger.info "┃ acs-promised"
            logger.info "┃ >> #{c('REQUEST', 'purple')}     [#{http_method}]: #{endpoint}"
            logger.info "┃ \t: #{sessionId}"
            logger.info "┃ \tsession id on demand : #{sessionIdOnDemand}" if sessionIdOnDemand
            logger.info "┃ \tparams:"
            logger.info "┃ \t\t#{k}: #{v}" for k, v of params
            logger.info "┗────────────────────────────────────────────────────────────────────────────────"

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
                    logger.error err if debug
                    reject err
                    return

                responseBody = JSON.parse(res.text)

                if debug
                    status = if responseBody.error then c(res.status, 'red') else c(res.status, 'green')

                    logger.info "\n"
                    logger.info "┏────────────────────────────────────────────────────────────────────────────────"
                    logger.info "┃ #{if logger.now? then logger.now() else new Date()}"
                    logger.info "┃ acs-promised"
                    logger.info "┃ << #{c('RESPONSE', 'cyan')} of [#{http_method}]: #{endpoint}"
                    logger.info "┃  \tsessionId: #{sessionId}"
                    logger.info "┃  \tstatus: #{status}"
                    for k, v of responseBody
                        logger.info "┃  \t#{k}:"
                        logger.info "┃  \t\t#{k2}: #{JSON.stringify(v2)}" for k2, v2 of v
                    logger.info "┗────────────────────────────────────────────────────────────────────────────────"

                if responseBody.error

                    err = new Error()
                    err.__proto__ = responseBody.error
                    err.isLoopBackResponseError = true

                    return reject(err)

                else
                    return resolve(responseBody)


    ###*
    creates client for LoopBack

    @method createClient
    @param {String} modelName
    @param {Object} [clientInfo]
    @param {String}  [clientInfo.accessToken] Access Token
    @param {Boolean} [clientInfo.debug] shows debug log if true
    @return {ACSClient}
    ###
    createClient: (modelName, clientInfo = {}) ->
        new LoopBackClient(
            @
            modelName
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
    @agentMethodMap :
        DELETE : 'del'
        PUT    : 'put'
        GET    : 'get'
        POST   : 'post'
        HEAD   : 'head'

    ###*
    gets JavaScript environment

    @private
    @static
    @method getEnv
    @return {String} env {ti|node|web}
    ###
    @getEnv: (env) ->

        env =
            if process?
                'node'
            else if Ti?
                'ti'
            else if window?
                'web'



    ###*
    gets logger object by JavaScript environment

    @private
    @static
    @method getLogger
    @param {String} [env] {ti|node|web}
    @return {Object} logger
    ###
    @getLogger: (env) ->

        env ?= @getEnv()

        switch env
            when 'ti'
                info  : (v) -> Ti.API.info(v)
                warn  : (v) -> Ti.API.info(v)
                error : (v) -> Ti.API.info(v)
                trace : (v) -> Ti.API.trace(v)
            when 'web'
                info  : (v) -> console.log('[INFO]',  v)
                warn  : (v) -> console.log('[WARN]',  v)
                error : (v) -> console.log('[ERROR]', v)
                trace : (v) -> console.log('[TRACE]', v)
            else
                console

module.exports = LoopBackPromised
