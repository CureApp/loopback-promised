
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

        yuidoc:
            options:
                paths: ['src']
                syntaxtype: 'coffee'
                extension: '.coffee'
            master:
                options:
                    outdir: "doc"


    grunt.loadNpmTasks 'grunt-mocha-test'
    grunt.loadNpmTasks 'grunt-contrib-yuidoc'
    grunt.loadNpmTasks 'grunt-contrib-coffee'

    grunt.registerTask 'default', 'mochaTest:spec'
    grunt.registerTask 'single', 'mochaTest:single'
    grunt.registerTask 'build', 'coffee:dist'
