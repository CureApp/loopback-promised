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

  DebugLogger.prototype.showResponseInfo = function(responseBody, status) {
    var tab;
    tab = tabs[0];
    status = responseBody.error ? colorize(status, 'red') : colorize(status, 'green');
    this.showHeader("<< " + (colorize('RESPONSE', 'cyan')));
    this.logger.info("┃ " + tab + "status: " + status);
    this.showParams('responseBody', responseBody, 1);
    this.showFooter();
  };

  return DebugLogger;

})();

module.exports = DebugLogger;
