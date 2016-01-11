var DebugLogger, LoopbackClient, LoopbackPromised, LoopbackRelatedClient, LoopbackUserClient, PushManager, superagent;

LoopbackClient = require('./loopback-client');

LoopbackUserClient = require('./loopback-user-client');

LoopbackRelatedClient = require('./loopback-related-client');

PushManager = require('./push-manager');

require('es6-promise').polyfill();

superagent = require('superagent');

DebugLogger = require('./util/debug-logger');


/**
LoopbackPromised

@class LoopbackPromised
@module loopback-promised
 */

LoopbackPromised = (function() {

  /**
  creates an instance
  
  @static
  @method createInstance
  @param {LoopbackPromised|Object} lbPromisedInfo
  @param {String} lbPromisedInfo.baseURL base URL of Loopback
  @param {Object} [lbPromisedInfo.logger] logger with info(), warn(), error(), trace().
  @param {String} [lbPromisedInfo.version] version of Loopback API to access
  @return {LoopbackPromised}
   */
  LoopbackPromised.createInstance = function(lbPromisedInfo) {
    if (lbPromisedInfo == null) {
      lbPromisedInfo = {};
    }
    return new LoopbackPromised(lbPromisedInfo.baseURL, lbPromisedInfo.logger, lbPromisedInfo.version);
  };


  /**
  
  @constructor
  @private
   */

  function LoopbackPromised(baseURL1, logger1, version1) {
    this.baseURL = baseURL1;
    this.logger = logger1;
    this.version = version1;
  }


  /**
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
   */

  LoopbackPromised.prototype.request = function(pluralModelName, path, params, http_method, clientInfo) {
    var endpoint;
    if (params == null) {
      params = {};
    }
    if (clientInfo == null) {
      clientInfo = {};
    }
    endpoint = "/" + pluralModelName + path;
    return this.constructor.requestStatic(endpoint, params, http_method, clientInfo, this);
  };


  /**
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
   */

  LoopbackPromised.requestStatic = function(endpoint, params, http_method, clientInfo, lbPromisedInfo) {
    var accessToken, agentMethod, baseURL, debug, debugLogger, logger, timeout, version;
    if (params == null) {
      params = {};
    }
    if (clientInfo == null) {
      clientInfo = {};
    }
    accessToken = clientInfo.accessToken, debug = clientInfo.debug, timeout = clientInfo.timeout;
    baseURL = lbPromisedInfo.baseURL, logger = lbPromisedInfo.logger, version = lbPromisedInfo.version;
    debug = this.isDebugMode(debug);
    if (debug) {
      debugLogger = new DebugLogger(endpoint, params, http_method, clientInfo, lbPromisedInfo);
    }
    agentMethod = this.agentMethodMap[http_method];
    if (!baseURL) {
      return Promise.reject('baseURL is required.');
    }
    if (agentMethod == null) {
      return Promise.reject(new Error("no agent method for http_method:  " + http_method));
    }
    if (debug) {
      debugLogger.showRequestInfo();
    }
    return new Promise(function(resolve, reject) {
      var flattenParams, k, req, url, v;
      url = version != null ? baseURL + '/' + version + endpoint : baseURL + endpoint;
      req = superagent[agentMethod](url);
      if (accessToken) {
        req.set('Authorization', accessToken);
      }
      if (agentMethod === 'get') {
        flattenParams = {};
        for (k in params) {
          v = params[k];
          if (typeof v === 'function') {
            continue;
          }
          flattenParams[k] = typeof v === 'object' ? JSON.stringify(v) : v;
        }
        req.query(flattenParams);
      } else if (Object.keys(params).length) {
        req.send(JSON.stringify(params));
        req.set('Content-Type', 'application/json');
      }
      if (timeout != null) {
        req.timeout(timeout);
      }
      return req.end(function(err, res) {
        var e, ref, responseBody;
        if (err) {
          if (debug) {
            debugLogger.showErrorInfo(err);
          }
          reject(err);
          return;
        }
        try {
          if (res.statusCode === 204) {
            responseBody = {};
          } else {
            responseBody = JSON.parse(res.text);
          }
        } catch (_error) {
          e = _error;
          responseBody = {
            error: res.text
          };
        }
        if (debug) {
          debugLogger.showResponseInfo(responseBody, res);
        }
        if (responseBody.error) {
          if (typeof responseBody.error === 'object') {
            err = new Error();
            ref = responseBody.error;
            for (k in ref) {
              v = ref[k];
              err[k] = v;
            }
            err.isLoopbackResponseError = true;
          } else {
            err = new Error(responseBody.error);
          }
          return reject(err);
        } else {
          return resolve(responseBody);
        }
      });
    });
  };


  /**
  creates client for Loopback
  
  @method createClient
  @param {String} pluralModelName
  @param {Object}  [options]
  @param {Object}  [options.belongsTo] key: pluralModelName (the "one" side of one-to-many relation), value: id
  @param {Boolean} [options.isUserModel] true if user model
  @param {String}  [options.accessToken] Access Token
  @param {Boolean} [options.debug] shows debug log if true
  @return {LoopbackClient}
   */

  LoopbackPromised.prototype.createClient = function(pluralModelName, options) {
    var id, pluralModelNameOne;
    if (options == null) {
      options = {};
    }
    if (options.belongsTo) {
      pluralModelNameOne = Object.keys(options.belongsTo)[0];
      id = options.belongsTo[pluralModelNameOne];
      return this.createRelatedClient({
        one: pluralModelNameOne,
        many: pluralModelName,
        id: id,
        timeout: options.timeout,
        accessToken: options.accessToken,
        debug: options.debug
      });
    } else if (options.isUserModel) {
      return this.createUserClient(pluralModelName, options);
    }
    return new LoopbackClient(this, pluralModelName, options.accessToken, options.timeout, options.debug);
  };


  /**
  creates user client for Loopback
  
  @method createUserClient
  @param {String} pluralModelName
  @param {Object} [clientInfo]
  @param {String}  [clientInfo.accessToken] Access Token
  @param {Boolean} [clientInfo.debug] shows debug log if true
  @return {LoopbackClient}
   */

  LoopbackPromised.prototype.createUserClient = function(pluralModelName, clientInfo) {
    if (clientInfo == null) {
      clientInfo = {};
    }
    return new LoopbackUserClient(this, pluralModelName, clientInfo.accessToken, clientInfo.timeout, clientInfo.debug);
  };


  /**
  creates related client (one-to-many relation)
  
  @method createRelatedClient
  @param {Object} options
  @param {String} options.one the "one" side plural model of one-to-many relationship
  @param {String} options.many the "many" side plural model of one-to-many relationship
  @param {any} options.id the id of the "one" model
  @param {String}  [options.accessToken] Access Token
  @param {Boolean} [options.debug] shows debug log if true
  @return {LoopbackClient}
   */

  LoopbackPromised.prototype.createRelatedClient = function(options) {
    return new LoopbackRelatedClient(this, options.one, options.many, options.id, options.accessToken, options.timeout, options.debug);
  };


  /**
  creates push manager
  
  @method createPushManager
  @public
  @param {Object} [clientInfo]
  @param {String}  [clientInfo.accessToken] Access Token
  @param {Boolean} [clientInfo.debug] shows debug log if true
  @return {PushManager}
   */

  LoopbackPromised.prototype.createPushManager = function(clientInfo) {
    if (clientInfo == null) {
      clientInfo = {};
    }
    return new PushManager(this, clientInfo.accessToken, clientInfo.debug);
  };


  /**
  check environment variable concerning debug
  
  @private
  @static
  @method isDebugMode
  @param {Boolean} debug
  @return {Boolean} shows debug log or not
   */

  LoopbackPromised.isDebugMode = function(debug) {
    var ref;
    return debug || !!(typeof process !== "undefined" && process !== null ? (ref = process.env) != null ? ref.LBP_DEBUG : void 0 : void 0);
  };


  /**
  HTTP methods => superagent methods
  
  @private
  @static
  @property agentMethodMap
  @type {Object}
   */

  LoopbackPromised.agentMethodMap = {
    DELETE: 'del',
    PUT: 'put',
    GET: 'get',
    POST: 'post',
    HEAD: 'head'
  };

  return LoopbackPromised;

})();

LoopbackPromised.Promise = Promise;

LoopbackPromised.LoopbackClient = LoopbackClient;

LoopbackPromised.LoopbackUserClient = LoopbackUserClient;

LoopbackPromised.LoopbackRelatedClient = LoopbackRelatedClient;

module.exports = LoopbackPromised;
