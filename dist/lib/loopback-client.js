var LoopBackClient, Promise, removeUndefinedKey;

Promise = require('es6-promise').Promise;


/**
LoopBack Client to access to PersistedModel (or extenders)

see http://docs.strongloop.com/display/public/LB/PersistedModel+REST+API
see also http://apidocs.strongloop.com/loopback/#persistedmodel

@class LoopBackClient
@module loopback-promised
 */

LoopBackClient = (function() {

  /**
  
  @constructor
  @param {LoopBackPromised} lbPromised
  @param {String} pluralModelName
  @param {String} [accessToken] Access Token
  @param {Boolean} [debug] shows debug log if true
   */
  function LoopBackClient(lbPromised, pluralModelName, accessToken, debug) {
    this.lbPromised = lbPromised;
    this.pluralModelName = pluralModelName;
    this.accessToken = accessToken;
    this.debug = debug;
  }


  /**
  sets Access Token
  
  @method setAccessToken
  @param {String} [accessToken] Access Token
  @return {Promise(Object)}
   */

  LoopBackClient.prototype.setAccessToken = function(accessToken) {
    this.accessToken = accessToken;
  };


  /**
  sends request to LoopBack
  
  @method request
  @private
  @param {String} path
  @param {Object} params request parameters
  @param {String} http_method {GET|POST|PUT|DELETE}
  @return {Promise(Object)}
   */

  LoopBackClient.prototype.request = function(path, params, http_method) {
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

  LoopBackClient.prototype.count = function(where) {
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
    return this.request(path, params, http_method);
  };


  /**
  Create new instance of Model class, saved in database
  
  @method create
  @param {Object} data
  @return {Promise(Object)}
   */

  LoopBackClient.prototype.create = function(data) {
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

  LoopBackClient.prototype.upsert = function(data) {
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

  LoopBackClient.prototype.exists = function(id) {
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

  LoopBackClient.prototype.findById = function(id) {
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

  LoopBackClient.prototype.find = function(filter) {
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

  LoopBackClient.prototype.findOne = function(filter) {
    var http_method, params, path;
    path = '/findOne';
    http_method = 'GET';
    params = {
      filter: filter
    };
    return this.request(path, params, http_method)["catch"](function(err) {
      if (err.isLoopBackResponseError && err.code === 'MODEL_NOT_FOUND') {
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

  LoopBackClient.prototype.destroyById = function(id) {
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

  LoopBackClient.prototype.destroy = function(data) {
    return this.destroyById(data.id);
  };


  /**
  Update set of attributes.
  
  @method updateAttributes
  @param {Object} data
  @return {Promise(Object)}
   */

  LoopBackClient.prototype.updateAttributes = function(id, data) {
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

  LoopBackClient.prototype.updateAll = function(where, data) {
    var http_method, params, path;
    path = "/update?where=" + (JSON.stringify(where));
    http_method = 'POST';
    params = data;
    return this.request(path, params, http_method);
  };

  return LoopBackClient;

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

module.exports = LoopBackClient;
