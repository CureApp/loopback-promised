Promise = require('es6-promise').Promise

###*
managing push notification.
Currently supports only for loopback servers build by [loopback-with-domain](https://github.com/cureapp/loopback-with-domain)

@class PushManager
###
class PushManager


    ###*
    @constructor
    @param {LoopbackPromised} lbPromised
    @param {String} accessToken
    @param {Boolean} debug
    ###
    constructor: (lbPromised, accessToken, debug, @appId) ->

        @pushClient = lbPromised.createClient('push', accessToken: accessToken, debug: debug)
        @installationClient = lbPromised.createClient('installation', accessToken: accessToken, debug: debug)
        @appId ?= 'loopback-with-admin'


    ###*
    start subscribing push notification

    @method subscribe
    @param {String} userId
    @param {String} deviceToken
    @param {String} deviceType (ios|android)
    @return {Promise}
    ###
    subscribe: (userId, deviceToken, deviceType) ->

        # if the deviceToken already used, delete the existing one
        @installationClient.find(where: deviceToken: deviceToken, deviceType: deviceType).then (installations) =>

            promises = (@installationClient.destroyById(ins.id) for ins in installations)

            return Promise.all promises

        .then =>
            # override userId if exists
            @installationClient.findOne(where: userId: userId).then (installation) =>

               installation ?= userId: userId

               installation.deviceType  = deviceType
               installation.deviceToken = deviceToken
               installation.appId       = @appId

               @installationClient.upsert(installation)


    ###*
    unsubcribe push notification

    @method unsubcribe
    @param {String} userId
    @return {Promise}
    ###
    unsubscribe: (userId) ->

        @installationClient.find(where: userId: userId).then (installations) =>

            promises = (@installationClient.destroyById(ins.id) for ins in installations)

            return Promise.all promises


    ###*
    send push notification

        notification =
            alert: 'hello, world!'
            sound: 'default.aiff'
            badge: 1

    @param {String} userId
    @param {Object} notification
    @return {Promise}

    ###
    notify: (userId, notification = {}) ->

        @pushClient.request("?deviceQuery[userId]=#{userId}", notification, 'POST')


module.exports = PushManager
