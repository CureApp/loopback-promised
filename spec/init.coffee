
config =
    models: require(__dirname + '/loopback-configs/model-definitions')
    server:
        port: 4157
        restApiRoot: '/test-api'


module.exports = require('loopback-with-domain').runWithoutDomain(config).catch console.log
