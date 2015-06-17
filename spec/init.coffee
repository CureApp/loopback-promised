
models = require(__dirname + '/loopback-configs/model-definitions')
config =
    server:
        port: 4157
        restApiRoot: '/test-api'
    admin:
        accessToken: 'test'


module.exports = require('loopback-with-admin').run(models, config).catch console.log
