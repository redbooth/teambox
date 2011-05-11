# Assets

Documentation about `css` and `js`:

  * Coding standards
  * Tests
  * Building process

## JS

  A - Should we make `JSLint|Hint` mandatory? If so, which flags?
  B - Which coding standard should be adopted?
  C - Which library should we use to test?
  D - Should we use a global namespace?
  E - Should we use loaders?
  F - Which minfier should be used?
  G - How does the client cache the file?
  H - How is the build done?

### Opinions / Answers

  A - Should we make `JSLint|Hint` mandatory? If so, which flags?

      We should use JSHint, is a little bit more flexible than JSLint.
      The flags I recommend are:
        `/*jshint browser: true, devel: true, jquery: true, debug: true, forin: true, undef: true, eqeqeq: true, bitwise: true, immed: true, laxbreak: true, noarg: true, noempty: true, nonew: true, indent: 2, maxlen: 120 */`

  B - Which coding standard should be adopted?

      JSLint provides your with a very strict coding standard.
      Although, by using `laxbreak` flag, we could use "comma first"
      as it helps to detect missing commas.

      ``` javascript
      var foo = 'bar';

      function () {
        var zemba = 'fleiba'; // <= Someone types `;` instead of ','
            foo = null;

        // BUG. We overwrite foo here.
      }
      ```
      ``` javascript
      // Comma first example
      var foo = 'bar';

      function () {
        var zemba = 'fleiba'
          , foo = null;

        // Easier to spot a missing comma
      }
      ```

  C - Which library should we use to test?

      Jasmine seems to be the favourite in the Rails community.

  D - Should we use a global namespace?

      I think `Teambox` is used now as a global namespace.
      I would use `TEAMBOX` instead. Is a good practice to use
      uppercase for global variables.

  E - Should we use loaders?

      Are there big files that are used rarely? If so I would split the
      giant js file and load them with a loader.

      Having a monolithic `js` file is not a good solution because every
      little change on any of the parts will expire the clients cached copy.

  F - Which minfier should be used?

      [UglifyJS](https://github.com/mishoo/UglifyJS) seems to be the best one right now.

  G - How does the client cache the file?

      Never expire (Expire: Thu, 28 Apr 2050 20:00:00 GMT).
      Expiration should be handled by file name.

      The js files name should be their hashed contents.
      That way, users will always have a fresh copy.

  H - How is the build done?

      --

Other opinions:
We should get rid of prototype. :)

## CSS

  * Which coding standard is adopted?
  * Which minfier is used?
  * Which caching HTTP headers are sent?
  * How does the client receive a recent deployed version?
