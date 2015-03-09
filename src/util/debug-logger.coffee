
tabs = ('    ' for i in [0..20])

colors =
  'red'    : '31'
  'green'  : '32'
  'yellow' : '33'
  'blue'   : '34'
  'purple' : '35'
  'cyan'   : '36'

colorsArr = Object.keys(colors)

env =
    if Ti?
        'ti'
    else if window?
        'web'
    else
        'node'


colorize =
    switch env
        when 'ti', 'node'
            (str, color) ->
                return str if not color or not colors[color]
                colorNum = colors[color]
                return "\u001b[#{colorNum}m#{str}\u001b[39m"

        when 'web'
            (str, color) ->
                return "[c=\"color: #{color}\"]#{str}[c]"



defaultLogger =
    switch env
        when 'ti'
            info  : (v) -> Ti.API.info(v)
            warn  : (v) -> Ti.API.info(v)
            error : (v) -> Ti.API.info(v)
            trace : (v) -> Ti.API.trace(v)

        when 'web'

            log = require('../../../bower_components/log/log')
            info  : (v) -> log(v)
            warn  : (v) -> log('[WARN] '  + v)
            error : (v) -> log('[ERROR] ' + v)
            trace : (v) -> log('[TRACE] ' + v)

        else
            console



class DebugLogger

    @counter : 0

    constructor: (@endpoint, @params, @http_method, @clientInfo, @lbPromisedInfo) ->

        { @accessToken, @debug } = @clientInfo

        { @baseURL, @logger, @version } = @lbPromisedInfo

        @logger ?= defaultLogger
        @logger.now = -> new Date()

        count = @constructor.counter = (@constructor.counter + 1) % colorsArr.length
        @color = colorsArr[count]
        @mark = colorize('●', @color)


    log: (vals...) ->
        @logger.info(@mark, vals...)

    showHeader: (title) ->
        tab = tabs[0]

        @logger.info "\n"
        @logger.info "┏────────────────────────────────────────────────────────────────────────────────"
        @logger.info "┃ #{@mark} #{@logger.now()}"
        @logger.info "┃ loopback-promised  #{@baseURL}"
        @logger.info "┃ #{title}  [#{@http_method}]: #{@endpoint}"
        @logger.info "┃ #{tab}accessToken: #{if @accessToken then @accessToken.slice(0, -10) + '...' else null}"
        return


    showFooter: ->
        @logger.info "┗────────────────────────────────────────────────────────────────────────────────"
        return



    showParams: (key, value, tabnum = 1, maxTab = 4) ->

        tab = tabs.slice(0, tabnum).join('')

        if Array.isArray value
            @logger.info "┃ #{tab}#{key}: [" 
            for v,i in value
                @showParams("[#{i}]", v, tabnum + 1, maxTab)

            @logger.info "┃ #{tab}]" 

        else if value? and typeof value is 'object' and Object.keys(value).length > 0 and tabnum <= maxTab
            @logger.info "┃ #{tab}#{key}:" 
            for own k, v of value
                @showParams(k, v, tabnum + 1, maxTab)
        else
            @logger.info "┃ #{tab}#{key}: #{JSON.stringify value}" 

        return


    showRequestInfo : ->

        tab = tabs[0]

        @showHeader ">> #{colorize('REQUEST', 'purple')}"
        @showParams('params', @params, 1)
        @showFooter()
        return


    showErrorInfo: (err) ->

        tab = tabs[0]

        @showHeader "<< #{colorize('ERROR', 'red')}"
        @showParams('Error', err, 1)
        @showFooter()
        return



    showResponseInfo: (responseBody, res) ->

        tab = tabs[0]
        status = if responseBody.error then colorize(res.status, 'red') else colorize(res.status, 'green')

        @showHeader "<< #{colorize('RESPONSE', 'cyan')}"
        @logger.info "┃ #{tab}status: #{status}"
        @showParams('responseBody', responseBody, 1)
        @showFooter()
        return


module.exports = DebugLogger
