

currentVersion = 'v0.0.11'

module.exports = (grunt) ->

    grunt.config.init

        'mocha-chai-sinon':
            spec:
                src: [
                    'spec/**/*.coffee'
                    '!spec/init.coffee'
                    '!spec/loopback-server/**/*.coffee'
                ]
                options:
                    ui: 'bdd'
                    reporter: 'spec'
                    require: 'coffee-script/register'

            single:
                src: [
                    grunt.option('file') ? 'spec/loopback-promised.coffee'
                ]
                options:
                    ui: 'bdd'
                    reporter: 'spec'
                    require: 'coffee-script/register'


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


    grunt.loadNpmTasks 'grunt-mocha-chai-sinon'
    grunt.loadNpmTasks 'grunt-contrib-yuidoc'
    grunt.loadNpmTasks 'grunt-browserify'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-bower-task'

    grunt.registerTask 'default', 'mocha-chai-sinon:spec'
    grunt.registerTask 'single', 'mocha-chai-sinon:single'
    grunt.registerTask 'build', ['coffee:dist', 'bower:dist', 'browserify:dist', 'uglify:dist', 'titaniumify', 'yuidoc']
