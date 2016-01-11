var LoopbackClient, LoopbackUserClient,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

LoopbackClient = require('./loopback-client');


/**
Loopback User Client to access to UserModel (or extenders)

see http://docs.strongloop.com/display/public/LB/PersistedModel+REST+API
see also http://apidocs.strongloop.com/loopback/#persistedmodel

@class LoopbackUserClient
@module loopback-promised
 */

LoopbackUserClient = (function(superClass) {
  extend(LoopbackUserClient, superClass);

  function LoopbackUserClient() {
    return LoopbackUserClient.__super__.constructor.apply(this, arguments);
  }


  /**
  Confirm the user's identity.
  
  @method confirm
  @param {String} userId
  @param {String} token The validation token
  @param {String} redirect URL to redirect the user to once confirmed
  @return {Promise(Object)}
   */

  LoopbackUserClient.prototype.confirm = function(userId, token, redirect) {
    var http_method, params, path;
    path = '/confirm';
    http_method = 'GET';
    params = {
      uid: userId,
      token: token,
      redirect: redirect
    };
    return this.request(path, params, http_method);
  };


  /**
  Login a user by with the given credentials
  
  @method login
  @param {Object} credentials email/password
  @param {String} include Optionally set it to "user" to include the user info
  @return {Promise(Object)}
   */

  LoopbackUserClient.prototype.login = function(credentials, include) {
    var http_method, params, path;
    path = '/login';
    if (include) {
      path += "?include=" + include;
    }
    http_method = 'POST';
    params = credentials;
    return this.request(path, params, http_method);
  };


  /**
  Logout a user with the given accessToken id.
  
  @method logout
  @param {String} accessTokenID
  @return {Promise}
   */

  LoopbackUserClient.prototype.logout = function(accessTokenID) {
    var http_method, params, path;
    path = "/logout?access_token=" + accessTokenID;
    http_method = 'POST';
    params = null;
    return this.request(path, params, http_method);
  };


  /**
  Create a short lived acess token for temporary login. Allows users to change passwords if forgotten.
  
  @method resetPassword
  @param {String} email
  @return {Promise}
   */

  LoopbackUserClient.prototype.resetPassword = function(email) {
    var http_method, params, path;
    path = "/logout?access_token=" + accessTokenID;
    http_method = 'POST';
    params = {
      email: email
    };
    return this.request(path, params, http_method);
  };

  return LoopbackUserClient;

})(LoopbackClient);

module.exports = LoopbackUserClient;
