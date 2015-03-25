var LoopBackClient, LoopBackRelatedClient, Promise,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Promise = require('es6-promise').Promise;

LoopBackClient = require('./loopback-client');


/**
LoopBack Client to access to PersistedModel (or extenders) via one-to-many relation

@class LoopBackRelatedClient
@extends LoopBackClient
@module loopback-promised
 */

LoopBackRelatedClient = (function(superClass) {
  extend(LoopBackRelatedClient, superClass);


  /**
  
  @constructor
  @param {LoopBackPromised} lbPromised
  @param {String} pluralModelName the "one" side plural model of one-to-many relationship
  @param {String} pluralModelNameMany the "many" side plural model of one-to-many relationship
  @param {any} id the id of the "one" model
  @param {String} [accessToken] Access Token
  @param {Boolean} [debug] shows debug log if true
  @return {LoopBackClient}
   */

  function LoopBackRelatedClient(lbPromised, pluralModelName, pluralModelNameMany, id1, accessToken, debug) {
    this.lbPromised = lbPromised;
    this.pluralModelName = pluralModelName;
    this.pluralModelNameMany = pluralModelNameMany;
    this.id = id1;
    this.accessToken = accessToken;
    this.debug = debug;
  }


  /**
  set id of the "one" model
  
  @method setAccessToken
  @param {any} id
  @return {Promise(Object)}
   */

  LoopBackRelatedClient.prototype.setId = function(id1) {
    this.id = id1;
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

  LoopBackRelatedClient.prototype.request = function(path, params, http_method) {
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

  LoopBackRelatedClient.prototype.upsert = function(data) {
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

  LoopBackRelatedClient.prototype.exists = function(id) {
    return this.findById(id).then(function(data) {
      return {
        exists: true
      };
    })["catch"](function(err) {
      if (err.isLoopBackResponseError) {
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

  LoopBackRelatedClient.prototype.findOne = function(filter) {
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

  LoopBackRelatedClient.prototype.updateAll = function(where, data) {
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

  return LoopBackRelatedClient;

})(LoopBackClient);

module.exports = LoopBackRelatedClient;
