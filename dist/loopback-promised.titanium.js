(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.loopbackPromised = f()}})(function(){var define,module,exports;return (function e(t,n,r){function o(i,u){if(!n[i]){if(!t[i]){var a=typeof require=="function"&&require;if(!u&&a)return a.length===2?a(i,!0):a(i);if(s&&s.length===2)return s(i,!0);if(s)return s(i);var f=new Error("Cannot find module '"+i+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[i]={exports:{}};t[i][0].call(l.exports,function(e){var n=t[i][1][e];return o(n?n:e)},l,l.exports,e,t,n,r)}return n[i].exports}var i=Array.prototype.slice;Function.prototype.bind||Object.defineProperty(Function.prototype,"bind",{enumerable:!1,configurable:!0,writable:!0,value:function(e){function r(){return t.apply(this instanceof r&&e?this:e,n.concat(i.call(arguments)))}if(typeof this!="function")throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable");var t=this,n=i.call(arguments,1);return r.prototype=Object.create(t.prototype),r.prototype.contructor=r,r}});var s=typeof require=="function"&&require;for(var u=0;u<r.length;u++)o(r[u]);return o})({1:[function(_dereq_,module,exports){
(function (console){

/**
Loopback Client to access to PersistedModel (or extenders)

see http://docs.strongloop.com/display/public/LB/PersistedModel+REST+API
see also http://apidocs.strongloop.com/loopback/#persistedmodel

@class LoopbackClient
@module loopback-promised
 */
var LoopbackClient, removeUndefinedKey;

LoopbackClient = (function() {

  /**
  
  @constructor
  @param {LoopbackPromised} lbPromised
  @param {String} pluralModelName
  @param {String} [accessToken] Access Token
  @param {Number} [timeout] msec to timeout
  @param {Boolean} [debug] shows debug log if true
   */
  function LoopbackClient(lbPromised, pluralModelName, accessToken, timeout, debug) {
    this.lbPromised = lbPromised;
    this.pluralModelName = pluralModelName;
    this.accessToken = accessToken;
    this.timeout = timeout;
    this.debug = debug;
  }


  /**
  sets Access Token
  
  @method setAccessToken
  @param {String} [accessToken] Access Token
  @return {Promise(Object)}
   */

  LoopbackClient.prototype.setAccessToken = function(accessToken) {
    this.accessToken = accessToken;
  };


  /**
  sends request to Loopback
  
  @method request
  @private
  @param {String} path
  @param {Object} params request parameters
  @param {String} http_method {GET|POST|PUT|DELETE}
  @return {Promise(Object)}
   */

  LoopbackClient.prototype.request = function(path, params, http_method) {
    if (params == null) {
      params = {};
    }
    return this.lbPromised.request(this.pluralModelName, path, params, http_method, this);
  };


  /**
  Return the number of records that match the optional "where" filter.
  
  @method count
  @param {Object} [where]
  @return {Promise(Number)}
   */

  LoopbackClient.prototype.count = function(where) {
    var http_method, params, path;
    if (where == null) {
      where = {};
    }
    path = '/count';
    http_method = 'GET';
    params = {};
    if (Object.keys(where)) {
      params.where = where;
    }
    return this.request(path, params, http_method).then(function(result) {
      return result.count;
    });
  };


  /**
  Create new instance of Model class, saved in database
  
  @method create
  @param {Object} data
  @return {Promise(Object)}
   */

  LoopbackClient.prototype.create = function(data) {
    var d, http_method, params, path;
    if (data == null) {
      data = {};
    }
    if (Array.isArray(data)) {
      return Promise.all((function() {
        var i, len, results;
        results = [];
        for (i = 0, len = data.length; i < len; i++) {
          d = data[i];
          results.push(this.create(d));
        }
        return results;
      }).call(this));
    }
    path = '';
    http_method = 'POST';
    params = data;
    return this.request(path, params, http_method);
  };


  /**
  Update or insert a model instance
  The update will override any specified attributes in the request data object. It won’t remove  existing ones unless the value is set to null.
  
  @method upsert
  @param {Object} data
  @return {Promise(Object)}
   */

  LoopbackClient.prototype.upsert = function(data) {
    var http_method, params, path;
    if (data == null) {
      data = {};
    }
    path = '';
    http_method = 'PUT';
    params = data;
    return this.request(path, params, http_method);
  };


  /**
  Check whether a model instance exists in database.
  
  @method exists
  @param {String} id
  @return {Promise(Object)}
   */

  LoopbackClient.prototype.exists = function(id) {
    var http_method, params, path;
    path = "/" + id + "/exists";
    http_method = 'GET';
    params = null;
    return this.request(path, params, http_method);
  };


  /**
  Find object by ID.
  
  @method findById
  @param {String} id
  @return {Promise(Object)}
   */

  LoopbackClient.prototype.findById = function(id) {
    var http_method, params, path;
    path = "/" + id;
    http_method = 'GET';
    params = null;
    return this.request(path, params, http_method);
  };


  /**
  Find all model instances that match filter specification.
  
  @method find
  @param {Object} filter
  @return {Promise(Array(Object))}
   */

  LoopbackClient.prototype.find = function(filter) {
    var http_method, params, path, where;
    if (filter != null ? filter.where : void 0) {
      where = removeUndefinedKey(filter.where);
      if (!where) {
        filter.where = null;
      }
    }
    if ((filter != null) && filter.where === null) {
      if (this.debug) {
        console.log("returns empty array, as \"where\" is null.");
      }
      return Promise.resolve([]);
    }
    path = '';
    http_method = 'GET';
    params = {
      filter: filter
    };
    return this.request(path, params, http_method);
  };


  /**
  Find one model instance that matches filter specification. Same as find, but limited to one result
  
  @method findOne
  @param {Object} filter
  @return {Promise(Object)}
   */

  LoopbackClient.prototype.findOne = function(filter) {
    var http_method, params, path;
    path = '/findOne';
    http_method = 'GET';
    params = {
      filter: filter
    };
    return this.request(path, params, http_method)["catch"](function(err) {
      if (err.isLoopbackResponseError && err.code === 'MODEL_NOT_FOUND') {
        return null;
      } else {
        throw err;
      }
    });
  };


  /**
  Destroy model instance with the specified ID.
  
  @method destroyById
  @param {String} id
  @return {Promise}
   */

  LoopbackClient.prototype.destroyById = function(id) {
    var http_method, params, path;
    path = "/" + id;
    http_method = 'DELETE';
    params = null;
    return this.request(path, params, http_method);
  };


  /**
  Destroy model instance
  
  @method destroy
  @param {Object} data
  @return {Promise}
   */

  LoopbackClient.prototype.destroy = function(data) {
    return this.destroyById(data.id);
  };


  /**
  Update set of attributes.
  
  @method updateAttributes
  @param {Object} data
  @return {Promise(Object)}
   */

  LoopbackClient.prototype.updateAttributes = function(id, data) {
    var http_method, params, path;
    path = "/" + id;
    http_method = 'PUT';
    params = data;
    return this.request(path, params, http_method);
  };


  /**
  Update multiple instances that match the where clause
  
  @method updateAll
  @param {Object} where
  @param {Object} data
  @return {Promise}
   */

  LoopbackClient.prototype.updateAll = function(where, data) {
    var http_method, params, path;
    path = "/update?where=" + (JSON.stringify(where));
    http_method = 'POST';
    params = data;
    return this.request(path, params, http_method);
  };

  return LoopbackClient;

})();

removeUndefinedKey = function(obj) {
  var deletedKeynum, key, keynum, value;
  if (typeof obj !== 'object' || obj === null) {
    return obj;
  }
  if (typeof (obj != null ? obj.toISOString : void 0) === 'function') {
    return obj.toISOString();
  }
  keynum = 0;
  deletedKeynum = 0;
  for (key in obj) {
    value = obj[key];
    value = removeUndefinedKey(value);
    if (value === void 0) {
      delete obj[key];
      deletedKeynum++;
    }
    keynum++;
  }
  if (keynum === deletedKeynum) {
    return void 0;
  } else {
    return obj;
  }
};

module.exports = LoopbackClient;

}).call(this,_dereq_("--console--"))
},{"--console--":19}],2:[function(_dereq_,module,exports){
(function (process){
var DebugLogger, LoopbackClient, LoopbackPromised, LoopbackRelatedClient, LoopbackUserClient, PushManager, superagent;

LoopbackClient = _dereq_('./loopback-client');

LoopbackUserClient = _dereq_('./loopback-user-client');

LoopbackRelatedClient = _dereq_('./loopback-related-client');

PushManager = _dereq_('./push-manager');

superagent = _dereq_('superagent');

DebugLogger = _dereq_('./util/debug-logger');


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

}).call(this,_dereq_("--process--"))
},{"--process--":12,"./loopback-client":1,"./loopback-related-client":3,"./loopback-user-client":4,"./push-manager":5,"./util/debug-logger":6,"superagent":10}],3:[function(_dereq_,module,exports){
var LoopbackClient, LoopbackRelatedClient,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

LoopbackClient = _dereq_('./loopback-client');


/**
Loopback Client to access to PersistedModel (or extenders) via one-to-many relation

@class LoopbackRelatedClient
@extends LoopbackClient
@module loopback-promised
 */

LoopbackRelatedClient = (function(superClass) {
  extend(LoopbackRelatedClient, superClass);


  /**
  
  @constructor
  @param {LoopbackPromised} lbPromised
  @param {String} pluralModelName the "one" side plural model of one-to-many relationship
  @param {String} pluralModelNameMany the "many" side plural model of one-to-many relationship
  @param {any} id the id of the "one" model
  @param {String} [accessToken] Access Token
  @param {Number} [timeout] msec to timeout
  @param {Boolean} [debug] shows debug log if true
  @return {LoopbackClient}
   */

  function LoopbackRelatedClient(lbPromised, pluralModelName, pluralModelNameMany, id1, accessToken, timeout, debug) {
    this.lbPromised = lbPromised;
    this.pluralModelName = pluralModelName;
    this.pluralModelNameMany = pluralModelNameMany;
    this.id = id1;
    this.accessToken = accessToken;
    this.timeout = timeout;
    this.debug = debug;
  }


  /**
  set id of the "one" model
  
  @method setAccessToken
  @param {any} id
  @return {Promise(Object)}
   */

  LoopbackRelatedClient.prototype.setId = function(id1) {
    this.id = id1;
  };


  /**
  sends request to Loopback
  
  @method request
  @private
  @param {String} path
  @param {Object} params request parameters
  @param {String} http_method {GET|POST|PUT|DELETE}
  @return {Promise(Object)}
   */

  LoopbackRelatedClient.prototype.request = function(path, params, http_method) {
    if (params == null) {
      params = {};
    }
    path = "/" + this.id + "/" + this.pluralModelNameMany + path;
    return this.lbPromised.request(this.pluralModelName, path, params, http_method, this);
  };


  /**
  Update or insert a model instance
  The update will override any specified attributes in the request data object. It won’t remove  existing ones unless the value is set to null.
  
  @method upsert
  @param {Object} data
  @return {Promise(Object)}
   */

  LoopbackRelatedClient.prototype.upsert = function(data) {
    var k, params, v;
    if (data == null) {
      data = {};
    }
    if (data.id != null) {
      params = {};
      for (k in data) {
        v = data[k];
        if (k !== 'id') {
          params[k] = v;
        }
      }
      return this.updateAttributes(data.id, params);
    } else {
      return this.create(data);
    }
  };


  /**
  Check whether a model instance exists in database.
  
  @method exists
  @param {String} id
  @return {Promise(Object)}
   */

  LoopbackRelatedClient.prototype.exists = function(id) {
    return this.findById(id).then(function(data) {
      return {
        exists: true
      };
    })["catch"](function(err) {
      if (err.isLoopbackResponseError) {
        return {
          exists: false
        };
      }
      throw err;
    });
  };


  /**
  Find one model instance that matches filter specification. Same as find, but limited to one result
  
  @method findOne
  @param {Object} filter
  @return {Promise(Object)}
   */

  LoopbackRelatedClient.prototype.findOne = function(filter) {
    return this.find(filter).then(function(results) {
      return results[0];
    });
  };


  /**
  Update multiple instances that match the where clause
  
  @method updateAll
  @param {Object} where
  @param {Object} data
  @return {Promise(Array(Object))}
   */

  LoopbackRelatedClient.prototype.updateAll = function(where, data) {
    return this.find({
      where: where,
      fields: 'id'
    }).then((function(_this) {
      return function(results) {
        var result;
        return Promise.all((function() {
          var i, len, results1;
          results1 = [];
          for (i = 0, len = results.length; i < len; i++) {
            result = results[i];
            results1.push(this.updateAttributes(result.id, data));
          }
          return results1;
        }).call(_this));
      };
    })(this));
  };

  return LoopbackRelatedClient;

})(LoopbackClient);

module.exports = LoopbackRelatedClient;

},{"./loopback-client":1}],4:[function(_dereq_,module,exports){
var LoopbackClient, LoopbackUserClient,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

LoopbackClient = _dereq_('./loopback-client');


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

},{"./loopback-client":1}],5:[function(_dereq_,module,exports){

/**
managing push notification.
Currently supports only for loopback servers build by [loopback-with-domain](https://github.com/cureapp/loopback-with-domain)

@class PushManager
 */
var PushManager;

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

},{}],6:[function(_dereq_,module,exports){
(function (console){
var DebugLogger, colorize, colors, colorsArr, defaultLogger, env, i, tabs,
  slice = [].slice,
  hasProp = {}.hasOwnProperty;

tabs = (function() {
  var j, results;
  results = [];
  for (i = j = 0; j <= 20; i = ++j) {
    results.push('    ');
  }
  return results;
})();

colors = {
  'red': '31',
  'green': '32',
  'yellow': '33',
  'blue': '34',
  'purple': '35',
  'cyan': '36'
};

colorsArr = Object.keys(colors);

env = typeof Ti !== "undefined" && Ti !== null ? 'ti' : typeof window !== "undefined" && window !== null ? 'web' : 'node';

colorize = (function() {
  switch (env) {
    case 'ti':
    case 'node':
      return function(str, color) {
        var colorNum;
        if (!color || !colors[color]) {
          return str;
        }
        colorNum = colors[color];
        return "\u001b[" + colorNum + "m" + str + "\u001b[39m";
      };
    case 'web':
      return function(str, color) {
        return "[c=\"color: " + color + "\"]" + str + "[c]";
      };
  }
})();

defaultLogger = (function() {
  switch (env) {
    case 'ti':
      return {
        info: function(v) {
          return Ti.API.info(v);
        },
        warn: function(v) {
          return Ti.API.info(v);
        },
        error: function(v) {
          return Ti.API.info(v);
        },
        trace: function(v) {
          return Ti.API.trace(v);
        }
      };
    case 'web':
      return {
        info: function(v) {
          return console.log(v);
        },
        warn: function(v) {
          return console.log('[WARN] ', v);
        },
        error: function(v) {
          return console.log('[ERROR] ', v);
        },
        trace: function(v) {
          return console.log('[TRACE] ', v);
        }
      };
    default:
      return console;
  }
})();

DebugLogger = (function() {
  DebugLogger.counter = 0;

  function DebugLogger(endpoint, params, http_method, clientInfo, lbPromisedInfo) {
    var count, ref, ref1;
    this.endpoint = endpoint;
    this.params = params;
    this.http_method = http_method;
    this.clientInfo = clientInfo;
    this.lbPromisedInfo = lbPromisedInfo;
    ref = this.clientInfo, this.accessToken = ref.accessToken, this.debug = ref.debug;
    ref1 = this.lbPromisedInfo, this.baseURL = ref1.baseURL, this.logger = ref1.logger, this.version = ref1.version;
    if (this.logger == null) {
      this.logger = defaultLogger;
    }
    this.logger.now = (function(_this) {
      return function() {
        var col, d, msec;
        if (!_this.startDate) {
          _this.startDate = new Date();
          return _this.startDate.toString();
        } else {
          d = new Date();
          msec = d.getTime() - _this.startDate.getTime();
          col = msec < 50 ? 'green' : msec < 250 ? 'yellow' : 'red';
          return (d.toString()) + " " + (colorize(msec + 'ms', col));
        }
      };
    })(this);
    count = this.constructor.counter = (this.constructor.counter + 1) % colorsArr.length;
    this.color = colorsArr[count];
    this.mark = colorize('●', this.color);
  }

  DebugLogger.prototype.log = function() {
    var ref, vals;
    vals = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return (ref = this.logger).info.apply(ref, [this.mark].concat(slice.call(vals)));
  };

  DebugLogger.prototype.showHeader = function(title) {
    var tab;
    tab = tabs[0];
    this.logger.info("\n");
    this.logger.info("┏────────────────────────────────────────────────────────────────────────────────");
    this.logger.info("┃ " + this.mark + " " + (this.logger.now()));
    this.logger.info("┃ loopback-promised  " + this.baseURL);
    this.logger.info("┃ " + title + "  [" + this.http_method + "]: " + this.endpoint);
    this.logger.info("┃ " + tab + "accessToken: " + (this.accessToken ? this.accessToken.slice(0, 20) + '...' : null));
  };

  DebugLogger.prototype.showFooter = function() {
    this.logger.info("┗────────────────────────────────────────────────────────────────────────────────");
  };

  DebugLogger.prototype.showParams = function(key, value, tabnum, maxTab) {
    var j, k, l, len, len1, line, lines, ref, tab, tab1, v;
    if (tabnum == null) {
      tabnum = 1;
    }
    if (maxTab == null) {
      maxTab = 4;
    }
    tab = tabs.slice(0, tabnum).join('');
    tab1 = tabs[0];
    if (Array.isArray(value)) {
      if (value.length === 0) {
        this.logger.info("┃ " + tab + key + ": []");
      } else {
        this.logger.info("┃ " + tab + key + ": [");
        for (i = j = 0, len = value.length; j < len; i = ++j) {
          v = value[i];
          this.showParams("[" + i + "]", v, tabnum + 1, maxTab);
        }
        this.logger.info("┃ " + tab + "]");
      }
    } else if (typeof (value != null ? value.toISOString : void 0) === 'function') {
      this.logger.info("┃ " + tab + key + ": [" + ((ref = value.constructor) != null ? ref.name : void 0) + "] " + (value.toISOString()));
    } else if (key === 'error' && typeof value === 'object' && typeof (value != null ? value.stack : void 0) === 'string') {
      this.logger.info("┃ " + tab + key + ":");
      for (k in value) {
        if (!hasProp.call(value, k)) continue;
        v = value[k];
        if (k === 'stack') {
          lines = v.split('\n');
          this.logger.info("┃ " + tab + tab1 + "stack:");
          for (l = 0, len1 = lines.length; l < len1; l++) {
            line = lines[l];
            this.logger.info("┃ " + tab + tab1 + tab1 + line);
          }
          continue;
        }
        this.showParams(k, v, tabnum + 1, maxTab);
      }
    } else if ((value != null) && typeof value === 'object' && Object.keys(value).length > 0 && tabnum <= maxTab) {
      this.logger.info("┃ " + tab + key + ":");
      for (k in value) {
        if (!hasProp.call(value, k)) continue;
        v = value[k];
        this.showParams(k, v, tabnum + 1, maxTab);
      }
    } else {
      this.logger.info("┃ " + tab + key + ": " + (JSON.stringify(value)));
    }
  };

  DebugLogger.prototype.showRequestInfo = function() {
    var tab;
    tab = tabs[0];
    this.showHeader(">> " + (colorize('REQUEST', 'purple')));
    this.showParams('params', this.params, 1);
    this.showFooter();
  };

  DebugLogger.prototype.showErrorInfo = function(err) {
    var tab;
    tab = tabs[0];
    this.showHeader("<< " + (colorize('ERROR', 'red')));
    this.showParams('Error', err, 1);
    this.showFooter();
  };

  DebugLogger.prototype.showResponseInfo = function(responseBody, res) {
    var status, tab;
    tab = tabs[0];
    status = responseBody.error ? colorize(res.status, 'red') : colorize(res.status, 'green');
    this.showHeader("<< " + (colorize('RESPONSE', 'cyan')));
    this.logger.info("┃ " + tab + "status: " + status);
    this.showParams('responseBody', responseBody, 1);
    this.showFooter();
  };

  return DebugLogger;

})();

module.exports = DebugLogger;

}).call(this,_dereq_("--console--"))
},{"--console--":19}],7:[function(_dereq_,module,exports){
(function (clearTimeout,setTimeout){
/**
 * Module dependencies.
 */

var Emitter = _dereq_('emitter');
var reduce = _dereq_('reduce');

/**
 * Root reference for iframes.
 */

var root = 'undefined' == typeof window
  ? this
  : window;

/**
 * Noop.
 */

function noop(){};

/**
 * Check if `obj` is a host object,
 * we don't want to serialize these :)
 *
 * TODO: future proof, move to compoent land
 *
 * @param {Object} obj
 * @return {Boolean}
 * @api private
 */

function isHost(obj) {
  var str = {}.toString.call(obj);

  switch (str) {
    case '[object File]':
    case '[object Blob]':
    case '[object FormData]':
      return true;
    default:
      return false;
  }
}

/**
 * Determine XHR.
 */

function getXHR() {
  if (root.XMLHttpRequest
    && ('file:' != root.location.protocol || !root.ActiveXObject)) {
    return new XMLHttpRequest;
  } else {
    try { return new ActiveXObject('Microsoft.XMLHTTP'); } catch(e) {}
    try { return new ActiveXObject('Msxml2.XMLHTTP.6.0'); } catch(e) {}
    try { return new ActiveXObject('Msxml2.XMLHTTP.3.0'); } catch(e) {}
    try { return new ActiveXObject('Msxml2.XMLHTTP'); } catch(e) {}
  }
  return false;
}

/**
 * Removes leading and trailing whitespace, added to support IE.
 *
 * @param {String} s
 * @return {String}
 * @api private
 */

var trim = ''.trim
  ? function(s) { return s.trim(); }
  : function(s) { return s.replace(/(^\s*|\s*$)/g, ''); };

/**
 * Check if `obj` is an object.
 *
 * @param {Object} obj
 * @return {Boolean}
 * @api private
 */

function isObject(obj) {
  return obj === Object(obj);
}

/**
 * Serialize the given `obj`.
 *
 * @param {Object} obj
 * @return {String}
 * @api private
 */

function serialize(obj) {
  if (!isObject(obj)) return obj;
  var pairs = [];
  for (var key in obj) {
    if (null != obj[key]) {
      pairs.push(encodeURIComponent(key)
        + '=' + encodeURIComponent(obj[key]));
    }
  }
  return pairs.join('&');
}

/**
 * Expose serialization method.
 */

 request.serializeObject = serialize;

 /**
  * Parse the given x-www-form-urlencoded `str`.
  *
  * @param {String} str
  * @return {Object}
  * @api private
  */

function parseString(str) {
  var obj = {};
  var pairs = str.split('&');
  var parts;
  var pair;

  for (var i = 0, len = pairs.length; i < len; ++i) {
    pair = pairs[i];
    parts = pair.split('=');
    obj[decodeURIComponent(parts[0])] = decodeURIComponent(parts[1]);
  }

  return obj;
}

/**
 * Expose parser.
 */

request.parseString = parseString;

/**
 * Default MIME type map.
 *
 *     superagent.types.xml = 'application/xml';
 *
 */

request.types = {
  html: 'text/html',
  json: 'application/json',
  xml: 'application/xml',
  urlencoded: 'application/x-www-form-urlencoded',
  'form': 'application/x-www-form-urlencoded',
  'form-data': 'application/x-www-form-urlencoded'
};

/**
 * Default serialization map.
 *
 *     superagent.serialize['application/xml'] = function(obj){
 *       return 'generated xml here';
 *     };
 *
 */

 request.serialize = {
   'application/x-www-form-urlencoded': serialize,
   'application/json': JSON.stringify
 };

 /**
  * Default parsers.
  *
  *     superagent.parse['application/xml'] = function(str){
  *       return { object parsed from str };
  *     };
  *
  */

request.parse = {
  'application/x-www-form-urlencoded': parseString,
  'application/json': JSON.parse
};

/**
 * Parse the given header `str` into
 * an object containing the mapped fields.
 *
 * @param {String} str
 * @return {Object}
 * @api private
 */

function parseHeader(str) {
  var lines = str.split(/\r?\n/);
  var fields = {};
  var index;
  var line;
  var field;
  var val;

  lines.pop(); // trailing CRLF

  for (var i = 0, len = lines.length; i < len; ++i) {
    line = lines[i];
    index = line.indexOf(':');
    field = line.slice(0, index).toLowerCase();
    val = trim(line.slice(index + 1));
    fields[field] = val;
  }

  return fields;
}

/**
 * Return the mime type for the given `str`.
 *
 * @param {String} str
 * @return {String}
 * @api private
 */

function type(str){
  return str.split(/ *; */).shift();
};

/**
 * Return header field parameters.
 *
 * @param {String} str
 * @return {Object}
 * @api private
 */

function params(str){
  return reduce(str.split(/ *; */), function(obj, str){
    var parts = str.split(/ *= */)
      , key = parts.shift()
      , val = parts.shift();

    if (key && val) obj[key] = val;
    return obj;
  }, {});
};

/**
 * Initialize a new `Response` with the given `xhr`.
 *
 *  - set flags (.ok, .error, etc)
 *  - parse header
 *
 * Examples:
 *
 *  Aliasing `superagent` as `request` is nice:
 *
 *      request = superagent;
 *
 *  We can use the promise-like API, or pass callbacks:
 *
 *      request.get('/').end(function(res){});
 *      request.get('/', function(res){});
 *
 *  Sending data can be chained:
 *
 *      request
 *        .post('/user')
 *        .send({ name: 'tj' })
 *        .end(function(res){});
 *
 *  Or passed to `.send()`:
 *
 *      request
 *        .post('/user')
 *        .send({ name: 'tj' }, function(res){});
 *
 *  Or passed to `.post()`:
 *
 *      request
 *        .post('/user', { name: 'tj' })
 *        .end(function(res){});
 *
 * Or further reduced to a single call for simple cases:
 *
 *      request
 *        .post('/user', { name: 'tj' }, function(res){});
 *
 * @param {XMLHTTPRequest} xhr
 * @param {Object} options
 * @api private
 */

function Response(req, options) {
  options = options || {};
  this.req = req;
  this.xhr = this.req.xhr;
  this.text = this.xhr.responseText;
  this.setStatusProperties(this.xhr.status);
  this.header = this.headers = parseHeader(this.xhr.getAllResponseHeaders());
  // getAllResponseHeaders sometimes falsely returns "" for CORS requests, but
  // getResponseHeader still works. so we get content-type even if getting
  // other headers fails.
  this.header['content-type'] = this.xhr.getResponseHeader('content-type');
  this.setHeaderProperties(this.header);
  this.body = this.req.method != 'HEAD'
    ? this.parseBody(this.text)
    : null;
}

/**
 * Get case-insensitive `field` value.
 *
 * @param {String} field
 * @return {String}
 * @api public
 */

Response.prototype.get = function(field){
  return this.header[field.toLowerCase()];
};

/**
 * Set header related properties:
 *
 *   - `.type` the content type without params
 *
 * A response of "Content-Type: text/plain; charset=utf-8"
 * will provide you with a `.type` of "text/plain".
 *
 * @param {Object} header
 * @api private
 */

Response.prototype.setHeaderProperties = function(header){
  // content-type
  var ct = this.header['content-type'] || '';
  this.type = type(ct);

  // params
  var obj = params(ct);
  for (var key in obj) this[key] = obj[key];
};

/**
 * Parse the given body `str`.
 *
 * Used for auto-parsing of bodies. Parsers
 * are defined on the `superagent.parse` object.
 *
 * @param {String} str
 * @return {Mixed}
 * @api private
 */

Response.prototype.parseBody = function(str){
  var parse = request.parse[this.type];
  return parse && str && str.length
    ? parse(str)
    : null;
};

/**
 * Set flags such as `.ok` based on `status`.
 *
 * For example a 2xx response will give you a `.ok` of __true__
 * whereas 5xx will be __false__ and `.error` will be __true__. The
 * `.clientError` and `.serverError` are also available to be more
 * specific, and `.statusType` is the class of error ranging from 1..5
 * sometimes useful for mapping respond colors etc.
 *
 * "sugar" properties are also defined for common cases. Currently providing:
 *
 *   - .noContent
 *   - .badRequest
 *   - .unauthorized
 *   - .notAcceptable
 *   - .notFound
 *
 * @param {Number} status
 * @api private
 */

Response.prototype.setStatusProperties = function(status){
  var type = status / 100 | 0;

  // status / class
  this.status = status;
  this.statusType = type;

  // basics
  this.info = 1 == type;
  this.ok = 2 == type;
  this.clientError = 4 == type;
  this.serverError = 5 == type;
  this.error = (4 == type || 5 == type)
    ? this.toError()
    : false;

  // sugar
  this.accepted = 202 == status;
  this.noContent = 204 == status || 1223 == status;
  this.badRequest = 400 == status;
  this.unauthorized = 401 == status;
  this.notAcceptable = 406 == status;
  this.notFound = 404 == status;
  this.forbidden = 403 == status;
};

/**
 * Return an `Error` representative of this response.
 *
 * @return {Error}
 * @api public
 */

Response.prototype.toError = function(){
  var req = this.req;
  var method = req.method;
  var url = req.url;

  var msg = 'cannot ' + method + ' ' + url + ' (' + this.status + ')';
  var err = new Error(msg);
  err.status = this.status;
  err.method = method;
  err.url = url;

  return err;
};

/**
 * Expose `Response`.
 */

request.Response = Response;

/**
 * Initialize a new `Request` with the given `method` and `url`.
 *
 * @param {String} method
 * @param {String} url
 * @api public
 */

function Request(method, url) {
  var self = this;
  Emitter.call(this);
  this._query = this._query || [];
  this.method = method;
  this.url = url;
  this.header = {};
  this._header = {};
  this.on('end', function(){
    try {
      var res = new Response(self);
      if ('HEAD' == method) res.text = null;
      self.callback(null, res);
    } catch(e) {
      var err = new Error('Parser is unable to parse the response');
      err.parse = true;
      err.original = e;
      self.callback(err);
    }
  });
}

/**
 * Mixin `Emitter`.
 */

Emitter(Request.prototype);

/**
 * Allow for extension
 */

Request.prototype.use = function(fn) {
  fn(this);
  return this;
}

/**
 * Set timeout to `ms`.
 *
 * @param {Number} ms
 * @return {Request} for chaining
 * @api public
 */

Request.prototype.timeout = function(ms){
  this._timeout = ms;
  return this;
};

/**
 * Clear previous timeout.
 *
 * @return {Request} for chaining
 * @api public
 */

Request.prototype.clearTimeout = function(){
  this._timeout = 0;
  clearTimeout(this._timer);
  return this;
};

/**
 * Abort the request, and clear potential timeout.
 *
 * @return {Request}
 * @api public
 */

Request.prototype.abort = function(){
  if (this.aborted) return;
  this.aborted = true;
  this.xhr.abort();
  this.clearTimeout();
  this.emit('abort');
  return this;
};

/**
 * Set header `field` to `val`, or multiple fields with one object.
 *
 * Examples:
 *
 *      req.get('/')
 *        .set('Accept', 'application/json')
 *        .set('X-API-Key', 'foobar')
 *        .end(callback);
 *
 *      req.get('/')
 *        .set({ Accept: 'application/json', 'X-API-Key': 'foobar' })
 *        .end(callback);
 *
 * @param {String|Object} field
 * @param {String} val
 * @return {Request} for chaining
 * @api public
 */

Request.prototype.set = function(field, val){
  if (isObject(field)) {
    for (var key in field) {
      this.set(key, field[key]);
    }
    return this;
  }
  this._header[field.toLowerCase()] = val;
  this.header[field] = val;
  return this;
};

/**
 * Remove header `field`.
 *
 * Example:
 *
 *      req.get('/')
 *        .unset('User-Agent')
 *        .end(callback);
 *
 * @param {String} field
 * @return {Request} for chaining
 * @api public
 */

Request.prototype.unset = function(field){
  delete this._header[field.toLowerCase()];
  delete this.header[field];
  return this;
};

/**
 * Get case-insensitive header `field` value.
 *
 * @param {String} field
 * @return {String}
 * @api private
 */

Request.prototype.getHeader = function(field){
  return this._header[field.toLowerCase()];
};

/**
 * Set Content-Type to `type`, mapping values from `request.types`.
 *
 * Examples:
 *
 *      superagent.types.xml = 'application/xml';
 *
 *      request.post('/')
 *        .type('xml')
 *        .send(xmlstring)
 *        .end(callback);
 *
 *      request.post('/')
 *        .type('application/xml')
 *        .send(xmlstring)
 *        .end(callback);
 *
 * @param {String} type
 * @return {Request} for chaining
 * @api public
 */

Request.prototype.type = function(type){
  this.set('Content-Type', request.types[type] || type);
  return this;
};

/**
 * Set Accept to `type`, mapping values from `request.types`.
 *
 * Examples:
 *
 *      superagent.types.json = 'application/json';
 *
 *      request.get('/agent')
 *        .accept('json')
 *        .end(callback);
 *
 *      request.get('/agent')
 *        .accept('application/json')
 *        .end(callback);
 *
 * @param {String} accept
 * @return {Request} for chaining
 * @api public
 */

Request.prototype.accept = function(type){
  this.set('Accept', request.types[type] || type);
  return this;
};

/**
 * Set Authorization field value with `user` and `pass`.
 *
 * @param {String} user
 * @param {String} pass
 * @return {Request} for chaining
 * @api public
 */

Request.prototype.auth = function(user, pass){
  var str = btoa(user + ':' + pass);
  this.set('Authorization', 'Basic ' + str);
  return this;
};

/**
* Add query-string `val`.
*
* Examples:
*
*   request.get('/shoes')
*     .query('size=10')
*     .query({ color: 'blue' })
*
* @param {Object|String} val
* @return {Request} for chaining
* @api public
*/

Request.prototype.query = function(val){
  if ('string' != typeof val) val = serialize(val);
  if (val) this._query.push(val);
  return this;
};

/**
 * Write the field `name` and `val` for "multipart/form-data"
 * request bodies.
 *
 * ``` js
 * request.post('/upload')
 *   .field('foo', 'bar')
 *   .end(callback);
 * ```
 *
 * @param {String} name
 * @param {String|Blob|File} val
 * @return {Request} for chaining
 * @api public
 */

Request.prototype.field = function(name, val){
  if (!this._formData) this._formData = new FormData();
  this._formData.append(name, val);
  return this;
};

/**
 * Queue the given `file` as an attachment to the specified `field`,
 * with optional `filename`.
 *
 * ``` js
 * request.post('/upload')
 *   .attach(new Blob(['<a id="a"><b id="b">hey!</b></a>'], { type: "text/html"}))
 *   .end(callback);
 * ```
 *
 * @param {String} field
 * @param {Blob|File} file
 * @param {String} filename
 * @return {Request} for chaining
 * @api public
 */

Request.prototype.attach = function(field, file, filename){
  if (!this._formData) this._formData = new FormData();
  this._formData.append(field, file, filename);
  return this;
};

/**
 * Send `data`, defaulting the `.type()` to "json" when
 * an object is given.
 *
 * Examples:
 *
 *       // querystring
 *       request.get('/search')
 *         .end(callback)
 *
 *       // multiple data "writes"
 *       request.get('/search')
 *         .send({ search: 'query' })
 *         .send({ range: '1..5' })
 *         .send({ order: 'desc' })
 *         .end(callback)
 *
 *       // manual json
 *       request.post('/user')
 *         .type('json')
 *         .send('{"name":"tj"})
 *         .end(callback)
 *
 *       // auto json
 *       request.post('/user')
 *         .send({ name: 'tj' })
 *         .end(callback)
 *
 *       // manual x-www-form-urlencoded
 *       request.post('/user')
 *         .type('form')
 *         .send('name=tj')
 *         .end(callback)
 *
 *       // auto x-www-form-urlencoded
 *       request.post('/user')
 *         .type('form')
 *         .send({ name: 'tj' })
 *         .end(callback)
 *
 *       // defaults to x-www-form-urlencoded
  *      request.post('/user')
  *        .send('name=tobi')
  *        .send('species=ferret')
  *        .end(callback)
 *
 * @param {String|Object} data
 * @return {Request} for chaining
 * @api public
 */

Request.prototype.send = function(data){
  var obj = isObject(data);
  var type = this.getHeader('Content-Type');

  // merge
  if (obj && isObject(this._data)) {
    for (var key in data) {
      this._data[key] = data[key];
    }
  } else if ('string' == typeof data) {
    if (!type) this.type('form');
    type = this.getHeader('Content-Type');
    if ('application/x-www-form-urlencoded' == type) {
      this._data = this._data
        ? this._data + '&' + data
        : data;
    } else {
      this._data = (this._data || '') + data;
    }
  } else {
    this._data = data;
  }

  if (!obj) return this;
  if (!type) this.type('json');
  return this;
};

/**
 * Invoke the callback with `err` and `res`
 * and handle arity check.
 *
 * @param {Error} err
 * @param {Response} res
 * @api private
 */

Request.prototype.callback = function(err, res){
  var fn = this._callback;
  if (2 == fn.length) return fn(err, res);
  if (err) return this.emit('error', err);
  fn(res);
};

/**
 * Invoke callback with x-domain error.
 *
 * @api private
 */

Request.prototype.crossDomainError = function(){
  var err = new Error('Origin is not allowed by Access-Control-Allow-Origin');
  err.crossDomain = true;
  this.callback(err);
};

/**
 * Invoke callback with timeout error.
 *
 * @api private
 */

Request.prototype.timeoutError = function(){
  var timeout = this._timeout;
  var err = new Error('timeout of ' + timeout + 'ms exceeded');
  err.timeout = timeout;
  this.callback(err);
};

/**
 * Enable transmission of cookies with x-domain requests.
 *
 * Note that for this to work the origin must not be
 * using "Access-Control-Allow-Origin" with a wildcard,
 * and also must set "Access-Control-Allow-Credentials"
 * to "true".
 *
 * @api public
 */

Request.prototype.withCredentials = function(){
  this._withCredentials = true;
  return this;
};

/**
 * Initiate request, invoking callback `fn(res)`
 * with an instanceof `Response`.
 *
 * @param {Function} fn
 * @return {Request} for chaining
 * @api public
 */

Request.prototype.end = function(fn){
  var self = this;
  var xhr = this.xhr = getXHR();
  var query = this._query.join('&');
  var timeout = this._timeout;
  var data = this._formData || this._data;

  // store callback
  this._callback = fn || noop;

  // state change
  xhr.onreadystatechange = function(){
    if (4 != xhr.readyState) return;
    if (0 == xhr.status) {
      if (self.aborted) return self.timeoutError();
      return self.crossDomainError();
    }
    self.emit('end');
  };

  // progress
  if (xhr.upload) {
    xhr.upload.onprogress = function(e){
      e.percent = e.loaded / e.total * 100;
      self.emit('progress', e);
    };
  }

  // timeout
  if (timeout && !this._timer) {
    this._timer = setTimeout(function(){
      self.abort();
    }, timeout);
  }

  // querystring
  if (query) {
    query = request.serializeObject(query);
    this.url += ~this.url.indexOf('?')
      ? '&' + query
      : '?' + query;
  }

  // initiate request
  xhr.open(this.method, this.url, true);

  // CORS
  if (this._withCredentials) xhr.withCredentials = true;

  // body
  if ('GET' != this.method && 'HEAD' != this.method && 'string' != typeof data && !isHost(data)) {
    // serialize stuff
    var serialize = request.serialize[this.getHeader('Content-Type')];
    if (serialize) data = serialize(data);
  }

  // set header fields
  for (var field in this.header) {
    if (null == this.header[field]) continue;
    xhr.setRequestHeader(field, this.header[field]);
  }

  // send stuff
  this.emit('request', this);
  xhr.send(data);
  return this;
};

/**
 * Expose `Request`.
 */

request.Request = Request;

/**
 * Issue a request:
 *
 * Examples:
 *
 *    request('GET', '/users').end(callback)
 *    request('/users').end(callback)
 *    request('/users', callback)
 *
 * @param {String} method
 * @param {String|Function} url or callback
 * @return {Request}
 * @api public
 */

function request(method, url) {
  // callback
  if ('function' == typeof url) {
    return new Request('GET', method).end(url);
  }

  // url first
  if (1 == arguments.length) {
    return new Request('GET', method);
  }

  return new Request(method, url);
}

/**
 * GET `url` with optional callback `fn(res)`.
 *
 * @param {String} url
 * @param {Mixed|Function} data or fn
 * @param {Function} fn
 * @return {Request}
 * @api public
 */

request.get = function(url, data, fn){
  var req = request('GET', url);
  if ('function' == typeof data) fn = data, data = null;
  if (data) req.query(data);
  if (fn) req.end(fn);
  return req;
};

/**
 * HEAD `url` with optional callback `fn(res)`.
 *
 * @param {String} url
 * @param {Mixed|Function} data or fn
 * @param {Function} fn
 * @return {Request}
 * @api public
 */

request.head = function(url, data, fn){
  var req = request('HEAD', url);
  if ('function' == typeof data) fn = data, data = null;
  if (data) req.send(data);
  if (fn) req.end(fn);
  return req;
};

/**
 * DELETE `url` with optional callback `fn(res)`.
 *
 * @param {String} url
 * @param {Function} fn
 * @return {Request}
 * @api public
 */

request.del = function(url, fn){
  var req = request('DELETE', url);
  if (fn) req.end(fn);
  return req;
};

/**
 * PATCH `url` with optional `data` and callback `fn(res)`.
 *
 * @param {String} url
 * @param {Mixed} data
 * @param {Function} fn
 * @return {Request}
 * @api public
 */

request.patch = function(url, data, fn){
  var req = request('PATCH', url);
  if ('function' == typeof data) fn = data, data = null;
  if (data) req.send(data);
  if (fn) req.end(fn);
  return req;
};

/**
 * POST `url` with optional `data` and callback `fn(res)`.
 *
 * @param {String} url
 * @param {Mixed} data
 * @param {Function} fn
 * @return {Request}
 * @api public
 */

request.post = function(url, data, fn){
  var req = request('POST', url);
  if ('function' == typeof data) fn = data, data = null;
  if (data) req.send(data);
  if (fn) req.end(fn);
  return req;
};

/**
 * PUT `url` with optional `data` and callback `fn(res)`.
 *
 * @param {String} url
 * @param {Mixed|Function} data or fn
 * @param {Function} fn
 * @return {Request}
 * @api public
 */

request.put = function(url, data, fn){
  var req = request('PUT', url);
  if ('function' == typeof data) fn = data, data = null;
  if (data) req.send(data);
  if (fn) req.end(fn);
  return req;
};

/**
 * Expose `request`.
 */

module.exports = request;

}).call(this,_dereq_("--timers--").clearTimeout,_dereq_("--timers--").setTimeout)
},{"--timers--":13,"emitter":8,"reduce":9}],8:[function(_dereq_,module,exports){

/**
 * Expose `Emitter`.
 */

module.exports = Emitter;

/**
 * Initialize a new `Emitter`.
 *
 * @api public
 */

function Emitter(obj) {
  if (obj) return mixin(obj);
};

/**
 * Mixin the emitter properties.
 *
 * @param {Object} obj
 * @return {Object}
 * @api private
 */

function mixin(obj) {
  for (var key in Emitter.prototype) {
    obj[key] = Emitter.prototype[key];
  }
  return obj;
}

/**
 * Listen on the given `event` with `fn`.
 *
 * @param {String} event
 * @param {Function} fn
 * @return {Emitter}
 * @api public
 */

Emitter.prototype.on =
Emitter.prototype.addEventListener = function(event, fn){
  this._callbacks = this._callbacks || {};
  (this._callbacks[event] = this._callbacks[event] || [])
    .push(fn);
  return this;
};

/**
 * Adds an `event` listener that will be invoked a single
 * time then automatically removed.
 *
 * @param {String} event
 * @param {Function} fn
 * @return {Emitter}
 * @api public
 */

Emitter.prototype.once = function(event, fn){
  var self = this;
  this._callbacks = this._callbacks || {};

  function on() {
    self.off(event, on);
    fn.apply(this, arguments);
  }

  on.fn = fn;
  this.on(event, on);
  return this;
};

/**
 * Remove the given callback for `event` or all
 * registered callbacks.
 *
 * @param {String} event
 * @param {Function} fn
 * @return {Emitter}
 * @api public
 */

Emitter.prototype.off =
Emitter.prototype.removeListener =
Emitter.prototype.removeAllListeners =
Emitter.prototype.removeEventListener = function(event, fn){
  this._callbacks = this._callbacks || {};

  // all
  if (0 == arguments.length) {
    this._callbacks = {};
    return this;
  }

  // specific event
  var callbacks = this._callbacks[event];
  if (!callbacks) return this;

  // remove all handlers
  if (1 == arguments.length) {
    delete this._callbacks[event];
    return this;
  }

  // remove specific handler
  var cb;
  for (var i = 0; i < callbacks.length; i++) {
    cb = callbacks[i];
    if (cb === fn || cb.fn === fn) {
      callbacks.splice(i, 1);
      break;
    }
  }
  return this;
};

/**
 * Emit `event` with the given args.
 *
 * @param {String} event
 * @param {Mixed} ...
 * @return {Emitter}
 */

Emitter.prototype.emit = function(event){
  this._callbacks = this._callbacks || {};
  var args = [].slice.call(arguments, 1)
    , callbacks = this._callbacks[event];

  if (callbacks) {
    callbacks = callbacks.slice(0);
    for (var i = 0, len = callbacks.length; i < len; ++i) {
      callbacks[i].apply(this, args);
    }
  }

  return this;
};

/**
 * Return array of callbacks for `event`.
 *
 * @param {String} event
 * @return {Array}
 * @api public
 */

Emitter.prototype.listeners = function(event){
  this._callbacks = this._callbacks || {};
  return this._callbacks[event] || [];
};

/**
 * Check if this emitter has `event` handlers.
 *
 * @param {String} event
 * @return {Boolean}
 * @api public
 */

Emitter.prototype.hasListeners = function(event){
  return !! this.listeners(event).length;
};

},{}],9:[function(_dereq_,module,exports){

/**
 * Reduce `arr` with `fn`.
 *
 * @param {Array} arr
 * @param {Function} fn
 * @param {Mixed} initial
 *
 * TODO: combatible error handling?
 */

module.exports = function(arr, fn, initial){  
  var idx = 0;
  var len = arr.length;
  var curr = arguments.length == 3
    ? initial
    : arr[idx++];

  while (idx < len) {
    curr = fn.call(null, curr, arr[idx], ++idx, arr);
  }
  
  return curr;
};
},{}],10:[function(_dereq_,module,exports){
(function (global){

;(function () {
  if (global === this) {

    global.window = global;

    global.XMLHttpRequest = function XMLHttpRequest() {
      var xhr = Ti.Network.createHTTPClient();

      if (typeof xhr.getResponseHeaders !== 'undefined') {
        xhr.getAllResponseHeaders = getAllResponseHeaders;
      }

      function getAllResponseHeaders() {
        var headers = xhr.getResponseHeaders();
        return Object.keys(headers).map(function (header) {
          return header + ':' + headers[header];
        }).join('\n') + '\n';
      }

      return xhr;
    };
  }
})();

var request = _dereq_('superagent');

function getXHR() {
  return new XMLHttpRequest();
}

request.Request.prototype.end = function (fn) {
  var self = this;
  var xhr = this.xhr = getXHR();
  var query = this._query.join('&');
  var timeout = this._timeout;
  var redirects = this._redirects;
  var data = this._data;

  // store callback
  this._callback = fn || noop;

  // state change
  xhr.onreadystatechange = function(){
    if (4 != xhr.readyState) return;
    if (0 == xhr.status) {
      if (self.aborted) return self.timeoutError();
      return;
    }
    if (self._finished) return;
    self._finished = true;
    self.emit('end');
  };

  xhr.onload = function () {
    if (self._finished) return;
    self._finished = true;
    self.emit('end');
  };

  xhr.onerror = function (error) {
    if (xhr.status > 0) {
      if (self._finished) return;
      self._finished = true;
      self.emit('end');
    }
    else {
      self.genericError(error);
    }
  };

  // timeout
  if (timeout) {
    xhr.timeout = timeout;
  }

  if (redirects != null) {
    this.redirects(redirects);
  }

  // querystring
  if (query) {
    query = request.serializeObject(query);
    this.url += ~this.url.indexOf('?')
      ? '&' + query
      : '?' + query;
  }

  // initiate request
  xhr.open(this.method, this.url, true);

  // CORS
  if (this._withCredentials) xhr.withCredentials = true;

  // body
  if ('GET' != this.method && 'HEAD' != this.method && 'string' != typeof data && !isHost(data)) {
    // serialize stuff
    var serialize = request.serialize[this.getHeader('Content-Type')];
    if (serialize) data = serialize(data);
  }

  // set header fields
  for (var field in this.header) {
    if (null == this.header[field]) continue;
    xhr.setRequestHeader(field, this.header[field]);
  }

  // send stuff
  this.emit('request', this);
  xhr.send(data);
  return this;
};

request.Request.prototype.genericError = function(error) {
  var err = new Error(error.error || 'Unknown error');

  for (var k in error) {
    if (k === 'source') continue;
    err[k] = error[k];
  }

  if (/timed?\s*out/i.test(err + '')) {
    err.timeout = this._timeout;
  }

  this.callback(err);
};

request.Request.prototype.timeout = function (timeout) {
  this._timeout = timeout;
  if (this.xhr) throw new Error("Cannot set the timeout once the HTTPClient has been created");
  return this;
};

request.Request.prototype.redirects = function (redirects) {
  this._redirects = redirects;
  if (redirects > 0 || redirects === true) {
    if (this.xhr) this.xhr.autoRedirect = true;
  }
  else if (redirects <= 0 || redirects === false) {
    if (this.xhr) this.xhr.autoRedirect = false;
  }
  return this;
};

// Not necessary in Titanium SDK 3.4, HTTPClient#getResponseHeader is (as the
// standard states) case insensitive.
// See https://jira.appcelerator.org/browse/TIMOB-17585 for reference,
// and https://github.com/appcelerator/titanium_mobile/pull/6053

var originalSetHeaderProperties = request.Response.prototype.setHeaderProperties;
request.Response.prototype.setHeaderProperties = function (header) {
  this.header['content-type'] =
    this.xhr.getResponseHeader('content-type') ||
    this.xhr.getResponseHeader('Content-Type');
  return originalSetHeaderProperties.call(this, header);
};

function isHost(obj) {
  var str = {}.toString.call(obj);

  switch (str) {
    case '[object File]':
    case '[object Blob]':
    case '[object FormData]':
      return true;
    default:
      return false;
  }
}

function noop() {}

module.exports = request;

}).call(this,_dereq_("--global--"))
},{"--global--":11,"superagent":7}],11:[function(_dereq_,module,exports){

module.exports = (function () { return this; })();

module.exports.location = {};

},{}],12:[function(_dereq_,module,exports){
(function (setTimeout){
/* global Ti:true, Titanium:true */

var process = module.exports = {};

process.nextTick = function nextTick(fn) {
  setTimeout(fn, 0);
};

process.title = 'titanium';
process.titanium = true;
process.env = {};
process.argv = [];

process.binding = function (name) {
  throw new Error('process.binding is not supported');
};

process.cwd = function () {
  return '/';
};

process.chdir = function (dir) {
  throw new Error('process.chdir is not supported');
};

process.stdout = {};
process.stderr = {};

process.stdout.write = function (msg) {
  Ti.API.info(msg);
};

process.stderr.write = function (msg) {
  Ti.API.error(msg);
};

'addEventListener removeEventListener removeListener hasEventListener fireEvent emit on off'.split(' ').forEach(function (name) {
  process[ name ] = noop;
});

function noop() {}

}).call(this,_dereq_("--timers--").setTimeout)
},{"--timers--":13}],13:[function(_dereq_,module,exports){
(function (global){

module.exports.clearInterval = clearInterval;
module.exports.clearTimeout = clearTimeout;
module.exports.setInterval = setInterval;
module.exports.setTimeout = setTimeout;

// See https://html.spec.whatwg.org/multipage/webappapis.html#dom-windowtimers-cleartimeout

function clearInterval(intervalId) {
  try {
    return global.clearInterval(intervalId);
  }
  catch (e) {
    // Do nothing
    return undefined;
  }
}

function clearTimeout(timeoutId) {
  try {
    return global.clearTimeout(timeoutId);
  }
  catch (e) {
    // Do nothing
    return undefined;
  }
}

function setInterval(func, delay) {
  var args = [];
  for (var i = 2, l = arguments.length; i < l; ++i) {
    args[ i - 2 ] = arguments[ i ];
  }

  return global.setInterval(function () {
    func.apply(this, args);
  }, +delay);
}

function setTimeout(func, delay) {
  var args = [];
  for (var i = 2, l = arguments.length; i < l; ++i) {
    args[ i - 2 ] = arguments[ i ];
  }

  return global.setTimeout(function () {
    func.apply(this, args);
  }, +delay);
}

}).call(this,_dereq_("--global--"))
},{"--global--":11}],14:[function(_dereq_,module,exports){
// http://wiki.commonjs.org/wiki/Unit_Testing/1.0
//
// THIS IS NOT TESTED NOR LIKELY TO WORK OUTSIDE V8!
//
// Originally from narwhal.js (http://narwhaljs.org)
// Copyright (c) 2009 Thomas Robinson <280north.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the 'Software'), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// when used in node, this will actually load the util module we depend on
// versus loading the builtin util module as happens otherwise
// this is a bug in node module loading as far as I am concerned
var util = _dereq_('util/');

var pSlice = Array.prototype.slice;
var hasOwn = Object.prototype.hasOwnProperty;

// 1. The assert module provides functions that throw
// AssertionError's when particular conditions are not met. The
// assert module must conform to the following interface.

var assert = module.exports = ok;

// 2. The AssertionError is defined in assert.
// new assert.AssertionError({ message: message,
//                             actual: actual,
//                             expected: expected })

assert.AssertionError = function AssertionError(options) {
  this.name = 'AssertionError';
  this.actual = options.actual;
  this.expected = options.expected;
  this.operator = options.operator;
  if (options.message) {
    this.message = options.message;
    this.generatedMessage = false;
  } else {
    this.message = getMessage(this);
    this.generatedMessage = true;
  }
  var stackStartFunction = options.stackStartFunction || fail;

  if (Error.captureStackTrace) {
    Error.captureStackTrace(this, stackStartFunction);
  }
  else {
    // non v8 browsers so we can have a stacktrace
    var err = new Error();
    if (err.stack) {
      var out = err.stack;

      // try to strip useless frames
      var fn_name = stackStartFunction.name;
      var idx = out.indexOf('\n' + fn_name);
      if (idx >= 0) {
        // once we have located the function frame
        // we need to strip out everything before it (and its line)
        var next_line = out.indexOf('\n', idx + 1);
        out = out.substring(next_line + 1);
      }

      this.stack = out;
    }
  }
};

// assert.AssertionError instanceof Error
util.inherits(assert.AssertionError, Error);

function replacer(key, value) {
  if (util.isUndefined(value)) {
    return '' + value;
  }
  if (util.isNumber(value) && !isFinite(value)) {
    return value.toString();
  }
  if (util.isFunction(value) || util.isRegExp(value)) {
    return value.toString();
  }
  return value;
}

function truncate(s, n) {
  if (util.isString(s)) {
    return s.length < n ? s : s.slice(0, n);
  } else {
    return s;
  }
}

function getMessage(self) {
  return truncate(JSON.stringify(self.actual, replacer), 128) + ' ' +
         self.operator + ' ' +
         truncate(JSON.stringify(self.expected, replacer), 128);
}

// At present only the three keys mentioned above are used and
// understood by the spec. Implementations or sub modules can pass
// other keys to the AssertionError's constructor - they will be
// ignored.

// 3. All of the following functions must throw an AssertionError
// when a corresponding condition is not met, with a message that
// may be undefined if not provided.  All assertion methods provide
// both the actual and expected values to the assertion error for
// display purposes.

function fail(actual, expected, message, operator, stackStartFunction) {
  throw new assert.AssertionError({
    message: message,
    actual: actual,
    expected: expected,
    operator: operator,
    stackStartFunction: stackStartFunction
  });
}

// EXTENSION! allows for well behaved errors defined elsewhere.
assert.fail = fail;

// 4. Pure assertion tests whether a value is truthy, as determined
// by !!guard.
// assert.ok(guard, message_opt);
// This statement is equivalent to assert.equal(true, !!guard,
// message_opt);. To test strictly for the value true, use
// assert.strictEqual(true, guard, message_opt);.

function ok(value, message) {
  if (!value) fail(value, true, message, '==', assert.ok);
}
assert.ok = ok;

// 5. The equality assertion tests shallow, coercive equality with
// ==.
// assert.equal(actual, expected, message_opt);

assert.equal = function equal(actual, expected, message) {
  if (actual != expected) fail(actual, expected, message, '==', assert.equal);
};

// 6. The non-equality assertion tests for whether two objects are not equal
// with != assert.notEqual(actual, expected, message_opt);

assert.notEqual = function notEqual(actual, expected, message) {
  if (actual == expected) {
    fail(actual, expected, message, '!=', assert.notEqual);
  }
};

// 7. The equivalence assertion tests a deep equality relation.
// assert.deepEqual(actual, expected, message_opt);

assert.deepEqual = function deepEqual(actual, expected, message) {
  if (!_deepEqual(actual, expected)) {
    fail(actual, expected, message, 'deepEqual', assert.deepEqual);
  }
};

function _deepEqual(actual, expected) {
  // 7.1. All identical values are equivalent, as determined by ===.
  if (actual === expected) {
    return true;

  } else if (util.isBuffer(actual) && util.isBuffer(expected)) {
    if (actual.length != expected.length) return false;

    for (var i = 0; i < actual.length; i++) {
      if (actual[i] !== expected[i]) return false;
    }

    return true;

  // 7.2. If the expected value is a Date object, the actual value is
  // equivalent if it is also a Date object that refers to the same time.
  } else if (util.isDate(actual) && util.isDate(expected)) {
    return actual.getTime() === expected.getTime();

  // 7.3 If the expected value is a RegExp object, the actual value is
  // equivalent if it is also a RegExp object with the same source and
  // properties (`global`, `multiline`, `lastIndex`, `ignoreCase`).
  } else if (util.isRegExp(actual) && util.isRegExp(expected)) {
    return actual.source === expected.source &&
           actual.global === expected.global &&
           actual.multiline === expected.multiline &&
           actual.lastIndex === expected.lastIndex &&
           actual.ignoreCase === expected.ignoreCase;

  // 7.4. Other pairs that do not both pass typeof value == 'object',
  // equivalence is determined by ==.
  } else if (!util.isObject(actual) && !util.isObject(expected)) {
    return actual == expected;

  // 7.5 For all other Object pairs, including Array objects, equivalence is
  // determined by having the same number of owned properties (as verified
  // with Object.prototype.hasOwnProperty.call), the same set of keys
  // (although not necessarily the same order), equivalent values for every
  // corresponding key, and an identical 'prototype' property. Note: this
  // accounts for both named and indexed properties on Arrays.
  } else {
    return objEquiv(actual, expected);
  }
}

function isArguments(object) {
  return Object.prototype.toString.call(object) == '[object Arguments]';
}

function objEquiv(a, b) {
  if (util.isNullOrUndefined(a) || util.isNullOrUndefined(b))
    return false;
  // an identical 'prototype' property.
  if (a.prototype !== b.prototype) return false;
  // if one is a primitive, the other must be same
  if (util.isPrimitive(a) || util.isPrimitive(b)) {
    return a === b;
  }
  var aIsArgs = isArguments(a),
      bIsArgs = isArguments(b);
  if ((aIsArgs && !bIsArgs) || (!aIsArgs && bIsArgs))
    return false;
  if (aIsArgs) {
    a = pSlice.call(a);
    b = pSlice.call(b);
    return _deepEqual(a, b);
  }
  var ka = objectKeys(a),
      kb = objectKeys(b),
      key, i;
  // having the same number of owned properties (keys incorporates
  // hasOwnProperty)
  if (ka.length != kb.length)
    return false;
  //the same set of keys (although not necessarily the same order),
  ka.sort();
  kb.sort();
  //~~~cheap key test
  for (i = ka.length - 1; i >= 0; i--) {
    if (ka[i] != kb[i])
      return false;
  }
  //equivalent values for every corresponding key, and
  //~~~possibly expensive deep test
  for (i = ka.length - 1; i >= 0; i--) {
    key = ka[i];
    if (!_deepEqual(a[key], b[key])) return false;
  }
  return true;
}

// 8. The non-equivalence assertion tests for any deep inequality.
// assert.notDeepEqual(actual, expected, message_opt);

assert.notDeepEqual = function notDeepEqual(actual, expected, message) {
  if (_deepEqual(actual, expected)) {
    fail(actual, expected, message, 'notDeepEqual', assert.notDeepEqual);
  }
};

// 9. The strict equality assertion tests strict equality, as determined by ===.
// assert.strictEqual(actual, expected, message_opt);

assert.strictEqual = function strictEqual(actual, expected, message) {
  if (actual !== expected) {
    fail(actual, expected, message, '===', assert.strictEqual);
  }
};

// 10. The strict non-equality assertion tests for strict inequality, as
// determined by !==.  assert.notStrictEqual(actual, expected, message_opt);

assert.notStrictEqual = function notStrictEqual(actual, expected, message) {
  if (actual === expected) {
    fail(actual, expected, message, '!==', assert.notStrictEqual);
  }
};

function expectedException(actual, expected) {
  if (!actual || !expected) {
    return false;
  }

  if (Object.prototype.toString.call(expected) == '[object RegExp]') {
    return expected.test(actual);
  } else if (actual instanceof expected) {
    return true;
  } else if (expected.call({}, actual) === true) {
    return true;
  }

  return false;
}

function _throws(shouldThrow, block, expected, message) {
  var actual;

  if (util.isString(expected)) {
    message = expected;
    expected = null;
  }

  try {
    block();
  } catch (e) {
    actual = e;
  }

  message = (expected && expected.name ? ' (' + expected.name + ').' : '.') +
            (message ? ' ' + message : '.');

  if (shouldThrow && !actual) {
    fail(actual, expected, 'Missing expected exception' + message);
  }

  if (!shouldThrow && expectedException(actual, expected)) {
    fail(actual, expected, 'Got unwanted exception' + message);
  }

  if ((shouldThrow && actual && expected &&
      !expectedException(actual, expected)) || (!shouldThrow && actual)) {
    throw actual;
  }
}

// 11. Expected to throw an error:
// assert.throws(block, Error_opt, message_opt);

assert.throws = function(block, /*optional*/error, /*optional*/message) {
  _throws.apply(this, [true].concat(pSlice.call(arguments)));
};

// EXTENSION! This is annoying to write outside this module.
assert.doesNotThrow = function(block, /*optional*/message) {
  _throws.apply(this, [false].concat(pSlice.call(arguments)));
};

assert.ifError = function(err) { if (err) {throw err;}};

var objectKeys = Object.keys || function (obj) {
  var keys = [];
  for (var key in obj) {
    if (hasOwn.call(obj, key)) keys.push(key);
  }
  return keys;
};

},{"util/":17}],15:[function(_dereq_,module,exports){
if (typeof Object.create === 'function') {
  // implementation from standard node.js 'util' module
  module.exports = function inherits(ctor, superCtor) {
    ctor.super_ = superCtor
    ctor.prototype = Object.create(superCtor.prototype, {
      constructor: {
        value: ctor,
        enumerable: false,
        writable: true,
        configurable: true
      }
    });
  };
} else {
  // old school shim for old browsers
  module.exports = function inherits(ctor, superCtor) {
    ctor.super_ = superCtor
    var TempCtor = function () {}
    TempCtor.prototype = superCtor.prototype
    ctor.prototype = new TempCtor()
    ctor.prototype.constructor = ctor
  }
}

},{}],16:[function(_dereq_,module,exports){
module.exports = function isBuffer(arg) {
  return arg && typeof arg === 'object'
    && typeof arg.copy === 'function'
    && typeof arg.fill === 'function'
    && typeof arg.readUInt8 === 'function';
}
},{}],17:[function(_dereq_,module,exports){
(function (process,global,console){
// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

var formatRegExp = /%[sdj%]/g;
exports.format = function(f) {
  if (!isString(f)) {
    var objects = [];
    for (var i = 0; i < arguments.length; i++) {
      objects.push(inspect(arguments[i]));
    }
    return objects.join(' ');
  }

  var i = 1;
  var args = arguments;
  var len = args.length;
  var str = String(f).replace(formatRegExp, function(x) {
    if (x === '%') return '%';
    if (i >= len) return x;
    switch (x) {
      case '%s': return String(args[i++]);
      case '%d': return Number(args[i++]);
      case '%j':
        try {
          return JSON.stringify(args[i++]);
        } catch (_) {
          return '[Circular]';
        }
      default:
        return x;
    }
  });
  for (var x = args[i]; i < len; x = args[++i]) {
    if (isNull(x) || !isObject(x)) {
      str += ' ' + x;
    } else {
      str += ' ' + inspect(x);
    }
  }
  return str;
};


// Mark that a method should not be used.
// Returns a modified function which warns once by default.
// If --no-deprecation is set, then it is a no-op.
exports.deprecate = function(fn, msg) {
  // Allow for deprecating things in the process of starting up.
  if (isUndefined(global.process)) {
    return function() {
      return exports.deprecate(fn, msg).apply(this, arguments);
    };
  }

  if (process.noDeprecation === true) {
    return fn;
  }

  var warned = false;
  function deprecated() {
    if (!warned) {
      if (process.throwDeprecation) {
        throw new Error(msg);
      } else if (process.traceDeprecation) {
        console.trace(msg);
      } else {
        console.error(msg);
      }
      warned = true;
    }
    return fn.apply(this, arguments);
  }

  return deprecated;
};


var debugs = {};
var debugEnviron;
exports.debuglog = function(set) {
  if (isUndefined(debugEnviron))
    debugEnviron = process.env.NODE_DEBUG || '';
  set = set.toUpperCase();
  if (!debugs[set]) {
    if (new RegExp('\\b' + set + '\\b', 'i').test(debugEnviron)) {
      var pid = process.pid;
      debugs[set] = function() {
        var msg = exports.format.apply(exports, arguments);
        console.error('%s %d: %s', set, pid, msg);
      };
    } else {
      debugs[set] = function() {};
    }
  }
  return debugs[set];
};


/**
 * Echos the value of a value. Trys to print the value out
 * in the best way possible given the different types.
 *
 * @param {Object} obj The object to print out.
 * @param {Object} opts Optional options object that alters the output.
 */
/* legacy: obj, showHidden, depth, colors*/
function inspect(obj, opts) {
  // default options
  var ctx = {
    seen: [],
    stylize: stylizeNoColor
  };
  // legacy...
  if (arguments.length >= 3) ctx.depth = arguments[2];
  if (arguments.length >= 4) ctx.colors = arguments[3];
  if (isBoolean(opts)) {
    // legacy...
    ctx.showHidden = opts;
  } else if (opts) {
    // got an "options" object
    exports._extend(ctx, opts);
  }
  // set default options
  if (isUndefined(ctx.showHidden)) ctx.showHidden = false;
  if (isUndefined(ctx.depth)) ctx.depth = 2;
  if (isUndefined(ctx.colors)) ctx.colors = false;
  if (isUndefined(ctx.customInspect)) ctx.customInspect = true;
  if (ctx.colors) ctx.stylize = stylizeWithColor;
  return formatValue(ctx, obj, ctx.depth);
}
exports.inspect = inspect;


// http://en.wikipedia.org/wiki/ANSI_escape_code#graphics
inspect.colors = {
  'bold' : [1, 22],
  'italic' : [3, 23],
  'underline' : [4, 24],
  'inverse' : [7, 27],
  'white' : [37, 39],
  'grey' : [90, 39],
  'black' : [30, 39],
  'blue' : [34, 39],
  'cyan' : [36, 39],
  'green' : [32, 39],
  'magenta' : [35, 39],
  'red' : [31, 39],
  'yellow' : [33, 39]
};

// Don't use 'blue' not visible on cmd.exe
inspect.styles = {
  'special': 'cyan',
  'number': 'yellow',
  'boolean': 'yellow',
  'undefined': 'grey',
  'null': 'bold',
  'string': 'green',
  'date': 'magenta',
  // "name": intentionally not styling
  'regexp': 'red'
};


function stylizeWithColor(str, styleType) {
  var style = inspect.styles[styleType];

  if (style) {
    return '\u001b[' + inspect.colors[style][0] + 'm' + str +
           '\u001b[' + inspect.colors[style][1] + 'm';
  } else {
    return str;
  }
}


function stylizeNoColor(str, styleType) {
  return str;
}


function arrayToHash(array) {
  var hash = {};

  array.forEach(function(val, idx) {
    hash[val] = true;
  });

  return hash;
}


function formatValue(ctx, value, recurseTimes) {
  // Provide a hook for user-specified inspect functions.
  // Check that value is an object with an inspect function on it
  if (ctx.customInspect &&
      value &&
      isFunction(value.inspect) &&
      // Filter out the util module, it's inspect function is special
      value.inspect !== exports.inspect &&
      // Also filter out any prototype objects using the circular check.
      !(value.constructor && value.constructor.prototype === value)) {
    var ret = value.inspect(recurseTimes, ctx);
    if (!isString(ret)) {
      ret = formatValue(ctx, ret, recurseTimes);
    }
    return ret;
  }

  // Primitive types cannot have properties
  var primitive = formatPrimitive(ctx, value);
  if (primitive) {
    return primitive;
  }

  // Look up the keys of the object.
  var keys = Object.keys(value);
  var visibleKeys = arrayToHash(keys);

  if (ctx.showHidden) {
    keys = Object.getOwnPropertyNames(value);
  }

  // IE doesn't make error fields non-enumerable
  // http://msdn.microsoft.com/en-us/library/ie/dww52sbt(v=vs.94).aspx
  if (isError(value)
      && (keys.indexOf('message') >= 0 || keys.indexOf('description') >= 0)) {
    return formatError(value);
  }

  // Some type of object without properties can be shortcutted.
  if (keys.length === 0) {
    if (isFunction(value)) {
      var name = value.name ? ': ' + value.name : '';
      return ctx.stylize('[Function' + name + ']', 'special');
    }
    if (isRegExp(value)) {
      return ctx.stylize(RegExp.prototype.toString.call(value), 'regexp');
    }
    if (isDate(value)) {
      return ctx.stylize(Date.prototype.toString.call(value), 'date');
    }
    if (isError(value)) {
      return formatError(value);
    }
  }

  var base = '', array = false, braces = ['{', '}'];

  // Make Array say that they are Array
  if (isArray(value)) {
    array = true;
    braces = ['[', ']'];
  }

  // Make functions say that they are functions
  if (isFunction(value)) {
    var n = value.name ? ': ' + value.name : '';
    base = ' [Function' + n + ']';
  }

  // Make RegExps say that they are RegExps
  if (isRegExp(value)) {
    base = ' ' + RegExp.prototype.toString.call(value);
  }

  // Make dates with properties first say the date
  if (isDate(value)) {
    base = ' ' + Date.prototype.toUTCString.call(value);
  }

  // Make error with message first say the error
  if (isError(value)) {
    base = ' ' + formatError(value);
  }

  if (keys.length === 0 && (!array || value.length == 0)) {
    return braces[0] + base + braces[1];
  }

  if (recurseTimes < 0) {
    if (isRegExp(value)) {
      return ctx.stylize(RegExp.prototype.toString.call(value), 'regexp');
    } else {
      return ctx.stylize('[Object]', 'special');
    }
  }

  ctx.seen.push(value);

  var output;
  if (array) {
    output = formatArray(ctx, value, recurseTimes, visibleKeys, keys);
  } else {
    output = keys.map(function(key) {
      return formatProperty(ctx, value, recurseTimes, visibleKeys, key, array);
    });
  }

  ctx.seen.pop();

  return reduceToSingleString(output, base, braces);
}


function formatPrimitive(ctx, value) {
  if (isUndefined(value))
    return ctx.stylize('undefined', 'undefined');
  if (isString(value)) {
    var simple = '\'' + JSON.stringify(value).replace(/^"|"$/g, '')
                                             .replace(/'/g, "\\'")
                                             .replace(/\\"/g, '"') + '\'';
    return ctx.stylize(simple, 'string');
  }
  if (isNumber(value))
    return ctx.stylize('' + value, 'number');
  if (isBoolean(value))
    return ctx.stylize('' + value, 'boolean');
  // For some reason typeof null is "object", so special case here.
  if (isNull(value))
    return ctx.stylize('null', 'null');
}


function formatError(value) {
  return '[' + Error.prototype.toString.call(value) + ']';
}


function formatArray(ctx, value, recurseTimes, visibleKeys, keys) {
  var output = [];
  for (var i = 0, l = value.length; i < l; ++i) {
    if (hasOwnProperty(value, String(i))) {
      output.push(formatProperty(ctx, value, recurseTimes, visibleKeys,
          String(i), true));
    } else {
      output.push('');
    }
  }
  keys.forEach(function(key) {
    if (!key.match(/^\d+$/)) {
      output.push(formatProperty(ctx, value, recurseTimes, visibleKeys,
          key, true));
    }
  });
  return output;
}


function formatProperty(ctx, value, recurseTimes, visibleKeys, key, array) {
  var name, str, desc;
  desc = Object.getOwnPropertyDescriptor(value, key) || { value: value[key] };
  if (desc.get) {
    if (desc.set) {
      str = ctx.stylize('[Getter/Setter]', 'special');
    } else {
      str = ctx.stylize('[Getter]', 'special');
    }
  } else {
    if (desc.set) {
      str = ctx.stylize('[Setter]', 'special');
    }
  }
  if (!hasOwnProperty(visibleKeys, key)) {
    name = '[' + key + ']';
  }
  if (!str) {
    if (ctx.seen.indexOf(desc.value) < 0) {
      if (isNull(recurseTimes)) {
        str = formatValue(ctx, desc.value, null);
      } else {
        str = formatValue(ctx, desc.value, recurseTimes - 1);
      }
      if (str.indexOf('\n') > -1) {
        if (array) {
          str = str.split('\n').map(function(line) {
            return '  ' + line;
          }).join('\n').substr(2);
        } else {
          str = '\n' + str.split('\n').map(function(line) {
            return '   ' + line;
          }).join('\n');
        }
      }
    } else {
      str = ctx.stylize('[Circular]', 'special');
    }
  }
  if (isUndefined(name)) {
    if (array && key.match(/^\d+$/)) {
      return str;
    }
    name = JSON.stringify('' + key);
    if (name.match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)) {
      name = name.substr(1, name.length - 2);
      name = ctx.stylize(name, 'name');
    } else {
      name = name.replace(/'/g, "\\'")
                 .replace(/\\"/g, '"')
                 .replace(/(^"|"$)/g, "'");
      name = ctx.stylize(name, 'string');
    }
  }

  return name + ': ' + str;
}


function reduceToSingleString(output, base, braces) {
  var numLinesEst = 0;
  var length = output.reduce(function(prev, cur) {
    numLinesEst++;
    if (cur.indexOf('\n') >= 0) numLinesEst++;
    return prev + cur.replace(/\u001b\[\d\d?m/g, '').length + 1;
  }, 0);

  if (length > 60) {
    return braces[0] +
           (base === '' ? '' : base + '\n ') +
           ' ' +
           output.join(',\n  ') +
           ' ' +
           braces[1];
  }

  return braces[0] + base + ' ' + output.join(', ') + ' ' + braces[1];
}


// NOTE: These type checking functions intentionally don't use `instanceof`
// because it is fragile and can be easily faked with `Object.create()`.
function isArray(ar) {
  return Array.isArray(ar);
}
exports.isArray = isArray;

function isBoolean(arg) {
  return typeof arg === 'boolean';
}
exports.isBoolean = isBoolean;

function isNull(arg) {
  return arg === null;
}
exports.isNull = isNull;

function isNullOrUndefined(arg) {
  return arg == null;
}
exports.isNullOrUndefined = isNullOrUndefined;

function isNumber(arg) {
  return typeof arg === 'number';
}
exports.isNumber = isNumber;

function isString(arg) {
  return typeof arg === 'string';
}
exports.isString = isString;

function isSymbol(arg) {
  return typeof arg === 'symbol';
}
exports.isSymbol = isSymbol;

function isUndefined(arg) {
  return arg === void 0;
}
exports.isUndefined = isUndefined;

function isRegExp(re) {
  return isObject(re) && objectToString(re) === '[object RegExp]';
}
exports.isRegExp = isRegExp;

function isObject(arg) {
  return typeof arg === 'object' && arg !== null;
}
exports.isObject = isObject;

function isDate(d) {
  return isObject(d) && objectToString(d) === '[object Date]';
}
exports.isDate = isDate;

function isError(e) {
  return isObject(e) &&
      (objectToString(e) === '[object Error]' || e instanceof Error);
}
exports.isError = isError;

function isFunction(arg) {
  return typeof arg === 'function';
}
exports.isFunction = isFunction;

function isPrimitive(arg) {
  return arg === null ||
         typeof arg === 'boolean' ||
         typeof arg === 'number' ||
         typeof arg === 'string' ||
         typeof arg === 'symbol' ||  // ES6 symbol
         typeof arg === 'undefined';
}
exports.isPrimitive = isPrimitive;

exports.isBuffer = _dereq_('./support/isBuffer');

function objectToString(o) {
  return Object.prototype.toString.call(o);
}


function pad(n) {
  return n < 10 ? '0' + n.toString(10) : n.toString(10);
}


var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep',
              'Oct', 'Nov', 'Dec'];

// 26 Feb 16:19:34
function timestamp() {
  var d = new Date();
  var time = [pad(d.getHours()),
              pad(d.getMinutes()),
              pad(d.getSeconds())].join(':');
  return [d.getDate(), months[d.getMonth()], time].join(' ');
}


// log is just a thin wrapper to console.log that prepends a timestamp
exports.log = function() {
  console.log('%s - %s', timestamp(), exports.format.apply(exports, arguments));
};


/**
 * Inherit the prototype methods from one constructor into another.
 *
 * The Function.prototype.inherits from lang.js rewritten as a standalone
 * function (not on Function.prototype). NOTE: If this file is to be loaded
 * during bootstrapping this function needs to be rewritten using some native
 * functions as prototype setup using normal JavaScript does not work as
 * expected during bootstrapping (see mirror.js in r114903).
 *
 * @param {function} ctor Constructor function which needs to inherit the
 *     prototype.
 * @param {function} superCtor Constructor function to inherit prototype from.
 */
exports.inherits = _dereq_('inherits');

exports._extend = function(origin, add) {
  // Don't do anything if add isn't an object
  if (!add || !isObject(add)) return origin;

  var keys = Object.keys(add);
  var i = keys.length;
  while (i--) {
    origin[keys[i]] = add[keys[i]];
  }
  return origin;
};

function hasOwnProperty(obj, prop) {
  return Object.prototype.hasOwnProperty.call(obj, prop);
}

}).call(this,_dereq_("--process--"),_dereq_("--global--"),_dereq_("--console--"))
},{"--console--":19,"--global--":11,"--process--":12,"./support/isBuffer":16,"inherits":15}],18:[function(_dereq_,module,exports){
module.exports = now

function now() {
    return new Date().getTime()
}

},{}],19:[function(_dereq_,module,exports){
var util = _dereq_("util");
var now = _dereq_("date-now");

var _console = {};
var times = {};

var functions = [
	['log','info'],
	['info','info'],
	['warn','warn'],
	['error','error']
];

functions.forEach(function(tuple) {
	_console[tuple[0]] = function() {
		Ti.API[tuple[1]](util.format.apply(util, arguments));
	};
});

_console.time = function(label) {
	times[label] = now();
};

_console.timeEnd = function(label) {
	var time = times[label];
	if (!time) {
		throw new Error("No such label: " + label);
	}

	var duration = now() - time;
	_console.log(label + ": " + duration + "ms");
};

_console.trace = function() {
	var err = new Error();
	err.name = "Trace";
	err.message = util.format.apply(null, arguments);
	_console.error(err.stack);
};

_console.dir = function(object) {
	_console.log(util.inspect(object) + "\n");
};

_console.assert = function(expression) {
	if (!expression) {
		var arr = Array.prototype.slice.call(arguments, 1);
		_dereq_("assert").ok(false, util.format.apply(null, arr));
	}
};

module.exports = _console;

},{"assert":14,"date-now":18,"util":17}]},{},[2])(2)
});
