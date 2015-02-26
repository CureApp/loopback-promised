
LoopBackClient = require('./loopback-client')

###*
LoopBack User Client to access to UserModel (or extenders)

see http://docs.strongloop.com/display/public/LB/PersistedModel+REST+API
see also http://apidocs.strongloop.com/loopback/#persistedmodel

@class LoopBackUserClient
@module loopback-promised
###
class LoopBackUserClient extends LoopBackClient


    ###*
    Confirm the user's identity.

    @method confirm
    @param {String} userId
    @param {String} token The validation token
    @param {String} redirect URL to redirect the user to once confirmed
    @return {Promise<Object>}
    ###
    confirm: (userId, token, redirect) ->

        path        = '/confirm'
        http_method = 'GET'

        params =
            uid      : userId
            token    : token
            redirect : redirect

        @request(path, params, http_method)


    ###*
    Confirm the user's identity.

    @method confirm
    @param {String} userId
    @param {String} token The validation token
    @param {String} redirect URL to redirect the user to once confirmed
    @return {Promise<Object>}
    ###
    confirm: (userId, token, redirect) ->

        path        = '/confirm'
        http_method = 'GET'

        params =
            uid      : userId
            token    : token
            redirect : redirect

        @request(path, params, http_method)


    ###*
    Login a user by with the given credentials

    @method login
    @param {Object} credentials email/password
    @param {String} include Optionally set it to "user" to include the user info
    @return {Promise<Object>}
    ###
    login: (credentials, include) ->

        path = '/login'
        path += "?include=#{include}" if include
        http_method = 'POST'

        params = credentials

        # TODO handle include option
        @request(path, params, http_method)


    ###*
    Logout a user with the given accessToken id.

    @method logout
    @param {String} accessTokenID
    @return {Promise}
    ###
    logout: (accessTokenID) ->

        path        = "/logout?access_token=#{accessTokenID}"
        http_method = 'POST'

        params = null

        @request(path, params, http_method)


    ###*
    Create a short lived acess token for temporary login. Allows users to change passwords if forgotten.

    @method resetPassword
    @param {String} email
    @return {Promise}
    ###
    resetPassword: (email) ->

        path        = "/logout?access_token=#{accessTokenID}"
        http_method = 'POST'

        params = email: email

        # TODO handle include option
        @request(path, params, http_method)


module.exports = LoopBackUserClient
