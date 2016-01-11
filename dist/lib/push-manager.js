var PushManager;

require('es6-promise').polyfill();


/**
managing push notification.
Currently supports only for loopback servers build by [loopback-with-domain](https://github.com/cureapp/loopback-with-domain)

@class PushManager
 */

PushManager = (function() {

  /**
  @constructor
  @param {LoopbackPromised} lbPromised
  @param {String} accessToken
  @param {Boolean} debug
   */
  function PushManager(lbPromised, accessToken, debug, appId) {
    this.appId = appId;
    this.pushClient = lbPromised.createClient('push', {
      accessToken: accessToken,
      debug: debug
    });
    this.installationClient = lbPromised.createClient('installation', {
      accessToken: accessToken,
      debug: debug
    });
    if (this.appId == null) {
      this.appId = 'loopback-with-admin';
    }
  }


  /**
  start subscribing push notification
  
  @method subscribe
  @param {String} userId
  @param {String} deviceToken
  @param {String} deviceType (ios|android)
  @return {Promise}
   */

  PushManager.prototype.subscribe = function(userId, deviceToken, deviceType) {
    return this.installationClient.find({
      where: {
        deviceToken: deviceToken,
        deviceType: deviceType
      }
    }).then((function(_this) {
      return function(installations) {
        var ins, promises;
        promises = (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = installations.length; i < len; i++) {
            ins = installations[i];
            results.push(this.installationClient.destroyById(ins.id));
          }
          return results;
        }).call(_this);
        return Promise.all(promises);
      };
    })(this)).then((function(_this) {
      return function() {
        return _this.installationClient.findOne({
          where: {
            userId: userId
          }
        }).then(function(installation) {
          if (installation == null) {
            installation = {
              userId: userId
            };
          }
          installation.deviceType = deviceType;
          installation.deviceToken = deviceToken;
          installation.appId = _this.appId;
          return _this.installationClient.upsert(installation);
        });
      };
    })(this));
  };


  /**
  unsubcribe push notification
  
  @method unsubcribe
  @param {String} userId
  @return {Promise}
   */

  PushManager.prototype.unsubscribe = function(userId) {
    return this.installationClient.find({
      where: {
        userId: userId
      }
    }).then((function(_this) {
      return function(installations) {
        var ins, promises;
        promises = (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = installations.length; i < len; i++) {
            ins = installations[i];
            results.push(this.installationClient.destroyById(ins.id));
          }
          return results;
        }).call(_this);
        return Promise.all(promises);
      };
    })(this));
  };


  /**
  send push notification
  
      notification =
          alert: 'hello, world!'
          sound: 'default.aiff'
          badge: 1
  
  @param {String} userId
  @param {Object} notification
  @return {Promise}
   */

  PushManager.prototype.notify = function(userId, notification) {
    if (notification == null) {
      notification = {};
    }
    return this.pushClient.request("?deviceQuery[userId]=" + userId, notification, 'POST');
  };

  return PushManager;

})();

module.exports = PushManager;
