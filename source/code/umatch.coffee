minimatch = require 'minimatch'

# Returns true if `filename` passes through the `specs` specs Array
# 
# @param String filename name of the filename, eg 'myfile.txt' 
#
# @param Array<String|RegExp|Function|Array> filename *specs* in minimatch or RegExp or Function (returning true for match),
#        with negative being '!' either as a 1st char of Strings or
#        as a plain '!' that negates the *spec* following (usefull to exclude matching RegExps, Functions and Arrays recursivelly).
#
# @todo: refactor to use a real agreement / _B.Blender
# @todo: move to glob-expand
umatch = module.exports = (filename, specs)-> #todo: (3 6 4) convert to proper In/in agreement
  finalAgree = false
  specs = [specs] if not _.isArray specs
  for agreement, idx in specs #go through all (no bailout when true) cause we have '!*glob*'
    agrees =
      if _.isString agreement
        if agreement[0] is '!'
          if agreement is '!'
            excludeIdx = idx + 1
          else
            excludeIdx = idx
          minimatch filename, agreement.slice(1)
        else
          minimatch filename, agreement
      else
        if _.isRegExp agreement
          !!filename.match agreement
        else
          if _.isFunction agreement
            agreement filename
          else
            if _.isArray agreement
              umatch filename, agreement
            else
              if not (_.isUndefined(agreement)  or _.isNull(agreement))
                throw new TypeError "umatch: invalid file spec type `#{typeof agreement}` with value `#{agreement}`"

    if  agrees is true
      if idx is excludeIdx
        finalAgree = false
      else
        finalAgree = true

  finalAgree

umatch.VERSION = if VERSION? then VERSION else '{NO_VERSION}'