
tabs = ('    ' for i in [0..20])

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
        tab = tabs[0]

        @logger.info """\n
          ┏────────────────────────────────────────────────────────────────────────────────
          ┃ #{@mark} #{@logger.now()}
          ┃ loopback-promised  #{@baseURL}
          ┃ #{title}  [#{@http_method}]: #{@endpoint}
          ┃ #{tab}accessToken: #{if @accessToken then @accessToken.slice(0, -10) + '...' else null}
          """
        return


    showFooter: ->
        @logger.info "┗────────────────────────────────────────────────────────────────────────────────"
        return



    showParams: (key, value, tabnum = 1, maxTab = 4) ->

        tab = tabs.slice(0, tabnum).join('')

        if typeof value is 'object' and Object.keys(value).length > 0 and tabnum <= maxTab
            @logger.info "┃ #{tab}#{key}:" 
            for k, v of value
                @showParams(k, v, tabnum + 1, maxTab)
        else
            @logger.info "┃ #{tab}#{key}: #{JSON.stringify value}" 

        return


    showRequestInfo : ->

        tab = tabs[0]

        @showHeader ">> #{c('REQUEST', 'purple')}"
        @showParams('params', @params, 1)
        @showFooter()
        return


    showErrorInfo: (err) ->

        tab = tabs[0]

        @showHeader "<< #{c('ERROR', 'red')}"
        @showParams('Error', err, 1)
        @showFooter()
        return



    showResponseInfo: (responseBody, res) ->

        tab = tabs[0]
        status = if responseBody.error then c(res.status, 'red') else c(res.status, 'green')

        @showHeader "<< #{c('RESPONSE', 'cyan')}"
        @logger.info "┃ #{tab}status: #{status}"
        @showParams('responseBody', responseBody, 1)
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
