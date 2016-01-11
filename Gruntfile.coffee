

currentVersion = 'v1.0.1'

module.exports = (grunt) ->

    grunt.config.init

        mochaTest:
            options:
                reporter: 'spec'
                require: [
                    'coffee-script/register'
                    'spec/export-globals.js'
                ]

            spec:
                src: [
                    'spec/*.coffee'
                    '!spec/init.coffee'
                    '!spec/model-definitions.coffee'
                ]

            single:
                src: [
                    grunt.option('file') ? 'spec/loopback-promised.coffee'
                ]


        coffee:
            dist:
                expand: true
                cwd: 'src/'
                src: ['**/*.coffee']
                dest: 'dist/lib/'
                ext: '.js'
                extDot: 'first'
                options:
                    bare: true

        bower:
            dist:
                options:
                    targetDir: 'bower_components'

        browserify:
            dist:
                files:
                    'dist/loopback-promised.web.js': 'web.js'

        uglify:
            dist:
                files:
                    'dist/loopback-promised.min.js' : 'dist/loopback-promised.web.js'

        yuidoc:
            options:
                paths: ['src']
                syntaxtype: 'coffee'
                extension: '.coffee'
            master:
                options:
                    outdir: "doc/#{currentVersion}"


    grunt.registerTask 'titaniumify',  ->

        done = @async()

        pack = require('titaniumifier').packer.pack
        cfg = {}
        packed = pack __dirname, cfg, () ->
            Promise = packed.constructor
            fs = require 'fs'
            Promise.props(packed).then (v) ->
                fs.writeFileSync __dirname + '/dist/loopback-promised.titanium.js', v.source
                done()


    grunt.loadNpmTasks 'grunt-mocha-test'
    grunt.loadNpmTasks 'grunt-contrib-yuidoc'
    grunt.loadNpmTasks 'grunt-browserify'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-bower-task'

    grunt.registerTask 'default', 'mochaTest:spec'
    grunt.registerTask 'single', 'mochaTest:single'
    grunt.registerTask 'build', ['coffee:dist', 'bower:dist', 'browserify:dist', 'uglify:dist', 'titaniumify']
