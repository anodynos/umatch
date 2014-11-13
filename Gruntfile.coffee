module.exports = gruntFunction = (grunt) ->
  gruntConfig =
    urequire:
      _all:
        dependencies: imports: {lodash: ['_']}
        template:
          name: 'nodejs'
          banner: true

      lib:
        path: 'source/code'
        dstPath: 'build/code'
        resources: [ 'inject-version' ]

      spec:
        path: 'source/spec'
        dstPath: 'build/spec'
        main: 'umatch-spec'
        dependencies: imports:
          umatch: 'umatch'
          chai: 'chai'
          specHelpers: 'spH'
        resources: [
          ['import-keys',
            'specHelpers': 'equalSet, equal, tru, fals'
            'chai': 'expect' ] ]
        afterBuild: require 'urequire-ab-specrunner'

      specWatch: derive: 'spec', watch: true

  splitTasks = (tasks)-> if (tasks instanceof Array) then tasks else tasks.split(/\s/).filter((f)->!!f)
  grunt.registerTask shortCut, "urequire:#{shortCut}" for shortCut of gruntConfig.urequire
  grunt.registerTask shortCut, splitTasks tasks for shortCut, tasks of {
    default: 'lib spec'
  }
  grunt.loadNpmTasks task for task of grunt.file.readJSON('package.json').devDependencies when task.lastIndexOf('grunt-', 0) is 0
  grunt.initConfig gruntConfig