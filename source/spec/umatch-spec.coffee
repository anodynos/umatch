files = [
  'file.txt'
  'path/file.coffee'
  'draft/mydraft.coffee'
  'literate/draft/*.coffee.md'
  'uRequireConfigUMD.coffee'
  'mytext.md'
  'draft/mydraft.txt'
  'badfile'
]

specFiltersFiles = (spec, expectedFilteredFiles)->
  equalSet (_.filter files, (f)-> umatch f, spec), expectedFilteredFiles

describe 'umatch filters', ->

  describe "no files, with specs being:", ->
    it "undefined", -> specFiltersFiles undefined, []
    it "null", -> specFiltersFiles null, []
    it "empty specs", -> specFiltersFiles [], []
    it "silly specs", -> specFiltersFiles ['silly', 'spec'], []
    it "`-> false`", -> specFiltersFiles [-> false], []

  describe "all files:", ->
    it "with `'**/*'`", -> specFiltersFiles ['**/*'], files
    it "with `/./`", -> specFiltersFiles [/./], files
    it "with `-> true`", -> specFiltersFiles [-> true], files

  describe "only files in root:", ->
    it "with `'*'`", -> specFiltersFiles ['*'], [
      'file.txt'
      'uRequireConfigUMD.coffee'
      'mytext.md'
      'badfile'
    ]

    it "only root files with extension `'*.*'`:", -> specFiltersFiles ['*.*'], [
      'file.txt'
      'uRequireConfigUMD.coffee'
      'mytext.md'
    ]

  describe "include or exclude specifics:", ->
    it "included by name", ->
      expectedFiles = [
        'path/file.coffee'
        'draft/mydraft.coffee'
        'uRequireConfigUMD.coffee'
        'mytext.md'
      ]
      specFiltersFiles expectedFiles, expectedFiles

    describe "included by extension:", ->
      expectedFiles = ['path/file.coffee', 'draft/mydraft.coffee', 'uRequireConfigUMD.coffee']

      it "with string spec", -> specFiltersFiles ['**/*.coffee'], expectedFiles
      it "with RegExp spec", -> specFiltersFiles [/.*\.coffee$/], expectedFiles
      it "with Function spec", -> specFiltersFiles [(f)-> f[f.length-6..] is 'coffee' ], expectedFiles

    describe "excluded by extension:", ->
      expectedFiles = [
        'file.txt'
        'literate/draft/*.coffee.md'
        'mytext.md'
        'draft/mydraft.txt'
        'badfile'
      ]

      it "with string spec", -> specFiltersFiles ['**/*', '!**/*.coffee'], expectedFiles
      it "with RegExp spec", -> specFiltersFiles [/./, '!', /.*\.coffee$/], expectedFiles
      it "with Function spec", -> specFiltersFiles [(->true), '!', (f)-> f[f.length-6..] is 'coffee' ], expectedFiles

    describe "included, then excluded:", ->
      expectedFiles = [
        'path/file.coffee'
        'uRequireConfigUMD.coffee'
        # excluded 'draft/mydraft.coffee'
      ]

      it "with string spec", -> specFiltersFiles ['**/*.coffee', '!*draft/*'], expectedFiles
      it "with RegExp spec", -> specFiltersFiles [/.*\.coffee$/, '!', /draft/], expectedFiles
      it "with Function spec", -> specFiltersFiles [
        (f)-> f[f.length-6..] is 'coffee'
        '!', (f)-> f.indexOf('draft') >= 0
      ], expectedFiles

    describe "excluded, then included:", ->
      expectedFiles = [
        'file.txt'
        'literate/draft/*.coffee.md'
        'mytext.md'
        'draft/mydraft.txt'
        'badfile'

        #included
        'draft/mydraft.coffee'
      ]

      it "with string spec", -> specFiltersFiles ['**/*', '!**/*.coffee', '*draft/*'], expectedFiles
      it "with RegExp spec", -> specFiltersFiles [/./, '!', /.*\.coffee$/, /draft/], expectedFiles
      it "with Function spec", -> specFiltersFiles [
        (->true)
        '!', (f)-> f[f.length-6..] is 'coffee'
        (f)-> f.indexOf('draft') >= 0
      ], expectedFiles

  describe "with String, RegExp, Function combined:", ->
    it "correctly filters files", ->
      specFiltersFiles [
        '**/*'
        '!**/draft/*.*'
        '!uRequireConfig*.*'
        '!', /.*\.md/
        '**/*.coffee.md'
        '**/draft/*.coffee'
        '!', (f)-> f is 'badfile'
      ], [
        'file.txt'
        'path/file.coffee'
        'draft/mydraft.coffee'
        'literate/draft/*.coffee.md'
      ]

  describe "A Function :", ->
    it "that returns false / falsey for all files matches no file, thus excludes nothing", ->
      specFiltersFiles [
        '**/*'
        (f)-> false
        (f)-> undefined
        (f)-> null
      ], files

    it "that returns true for all files matches all files, thus includes all files", ->
      specFiltersFiles [(f)-> true], files

    it "that matches one file and has negation, excludes only that one file", ->
      specFiltersFiles [/./, '!', (f)-> f is 'file.txt'], files.filter (f)-> f isnt 'file.txt'

  describe "An Array ", ->
    someFiles = ['file.txt', 'path/file.coffee']

    it "that matches no files, excludes nothing", ->
      specFiltersFiles [
        '**/*'
        ['missing', 'irrelevant']
      ], files

    it "that matches some files, includes those files", ->
      specFiltersFiles [ someFiles ], someFiles

    it "is recursivelly processed", ->
      specFiltersFiles [ [ [ someFiles ] ] ], someFiles

    it "that matches some files and has negation, excludes only those files", ->
      specFiltersFiles [/./, '!', someFiles], files.filter (f)-> f not in someFiles

  describe "Bad specs", ->

    it "throw a TypeError exception ", ->
      expect(-> umatch "somefile", [1]).to.throw TypeError
      expect(-> umatch "somefile", [{}]).to.throw TypeError
      expect(-> umatch "somefile", [true]).to.throw TypeError