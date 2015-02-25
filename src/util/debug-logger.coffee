
tabs = ('\t' for i in [0..20]).join('')

colors =
  'red'    : '31'
  'green'  : '32'
  'yellow' : '33'
  'blue'   : '34'
  'purple' : '35'
  'cyan'   : '36'

colorsArr = Object.keys(colors)

c = (str, color) ->
    return str if not color or not colors[color]
    colorNum = colors[color]

    return "\u001b[#{colorNum}m#{str}\u001b[39m"


class DebugLogger

    @counter : 0

    constructor: (@endpoint, @params, @http_method, @clientInfo, @lbPromisedInfo) ->

        { @accessToken, @debug } = @clientInfo

        { @baseURL, @logger, @version } = @lbPromisedInfo

        @logger ?= @constructor.getLogger()
        @logger.now ?= -> new Date()

        count = @constructor.counter = (@constructor.counter + 1) % colorsArr.length
        @color = colorsArr[count]
        @mark = c('●', @color)


    log: (vals...) ->
        @logger.info(@mark, vals...)

    showHeader: (title) ->

        @logger.info "\n"
        @logger.info "┏────────────────────────────────────────────────────────────────────────────────"
        @logger.info "┃ #{@mark} #{@logger.now()}"
        @logger.info "┃ loopback-promised  #{@baseURL}"
        @logger.info "┃ #{title}  [#{@http_method}]: #{@endpoint}"
        @logger.info "┃ \tAccess Token: #{if @accessToken then @accessToken.slice(0, -10) + '...' else null}"
        return


    showFooter: ->
        @logger.info "┗────────────────────────────────────────────────────────────────────────────────"
        return



    showParams: (params, tabnum = 1, maxTab = 4) ->

        tab = tabs.slice(0, tabnum)

        for k, v of params
            if typeof v is 'object' and tabnum <= maxTab
                @logger.info "┃  #{tab}#{k}:" 
                @showParams(v, tabnum + 1, maxTab)
            else
                @logger.info "┃  #{tab}#{k}: #{JSON.stringify v}" 

        return


    showRequestInfo : ->

        @showHeader ">> #{c('REQUEST', 'purple')}"
        @logger.info "┃ \tparams:"
        @showParams(@params, 1)
        @showFooter()
        return


    showErrorInfo: (err) ->

        @showHeader "<< #{c('ERROR', 'red')}"
        @logger.info "┃  \tError: "
        @showParams(err, 2)
        @showFooter()
        return



    showResponseInfo: (responseBody, res) ->
        status = if responseBody.error then c(res.status, 'red') else c(res.status, 'green')
        @showHeader "<< #{c('RESPONSE', 'cyan')}"
        @logger.info "┃  \tstatus: #{status}"
        @logger.info "┃  \tresponseBody: "
        @showParams(responseBody, 2)
        @showFooter()
        return



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


module.exports = DebugLogger
