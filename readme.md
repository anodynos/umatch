# umatch

[![Build Status](https://travis-ci.org/anodynos/umatch.svg?branch=master)](https://travis-ci.org/anodynos/umatch)
[![Up to date Status](https://david-dm.org/anodynos/umatch.png)](https://david-dm.org/anodynos/umatch.png)

A `function(filename, specs)` thats checks if `'someFile.ext'` passes through an of Array of `minimatch` / `RegExp` / `callbacks` / `Array` (recursive) specs, with negation/exclusion '!' flag for all.

_Note: `umatch` replaces the deprecated [`is_file_in`](http://github.com/anodynos/is_file_in) with extending behavior._

The Array of filename specifications (or simply filenames), can expressed in either:

  * `String` in *gruntjs*'s-like expand `minimatch` format (eg `'**/*.coffee'`) and its exclusion cousin (eg `'!**/DRAFT*.*'`)


  * `RegExp`s that matche filenames (eg `/./`) again with a negation / exclusion pattern.

    ```
    [..., '!', /regexp/, ...]
    ```


  * A `function(filename){}` callback, returning `true` if filename is to be matched. Consistently it can have a negation / exclusion flag before it:


    ```
    [..., '!', function(f){ return f === 'excludeMe.js' }, ...]
    ```

    Note the trap with negation flag: always use a `true` (i.e matched) as the function result, preceded by '!' for **exclusion**. Only the `true` return value is considered by `umatch` (which means **it matched**), and the possible exclusion before it excludes those that did actually match. In other words, you will be happy to know that, `['!', function(){return false}]` does NOT mean *include all*, only `[ function(){return true} ]` does.

    The common trap is to return a `false` for your *excluded matches* (which means nothing) and then all your non-excluded will match with `true`, which is probably not what you want! Instead use a `true` (i.e match) and then use the negation '!' before the function.

    As a rule of thumb remember that double negation (exclusion + false) is NOT positive (inclusion).


  * An `Array<String|RegExp|Function|Array>, recursive, i.e


     ```
     [ ..., '!', ['DontAllowMe*.*', function(f){ return f === 'excludeme.js' }, [.., []], ...], ...]
     ```

  The same rules for `Function` apply here: only matched filenames are considered for inclusion, or exclusion if the array is preceded by `'!'`.

# Examples

```javascript

  var specs = [
    '**/recources/*',
    '!badFile.json',
    /.*\.someExtension$/i, '!',
    /.*\.excludeExtension$/i,
    function(fn) { return fn === 'includedFile.ext' },
    '!', function(fn) { return _.startsWith('DRAFT') }
  ];

  umatch('someFile.someExtension', specs) // true

  umatch('someFile.otherExtension', specs) // false

  umatch('includedFile.ext', specs) //true

  umatch('DRAFTFile.ext', specs) // false

```

See the [specs](https://github.com/anodynos/umatch/blob/master/source/spec/umatch-spec.coffee) for more examples.

# License

The MIT License

Copyright (c) 2013-2014 Agelos Pikoulas (agelos.pikoulas@gmail.com)

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
