
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
            lib:
                expand: true
                cwd: 'src/'
                src: ['**/*.coffee']
                dest: 'lib/'
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
                    outdir: 'doc'



    grunt.loadNpmTasks 'grunt-mocha-chai-sinon'
    grunt.loadNpmTasks 'grunt-contrib-yuidoc'
    grunt.loadNpmTasks 'grunt-contrib-coffee'

    grunt.registerTask 'default', 'mocha-chai-sinon:spec'
    grunt.registerTask 'single', 'mocha-chai-sinon:single'
    grunt.registerTask 'build', 'coffee:lib'
