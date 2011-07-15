/*globals WebPage, phantom*/

(function () {

  /**
   * Wait until the test condition is true or a timeout occurs. Useful for waiting
   * on a server response or for a ui change (fadeIn, etc.) to occur.
   *
   * @param {Function} condition It will be evaluated every x Seconds
   * @param {Object} options
   * @param {Function} callback
   * @return {Object} interval
   */
  function _waitFor(condition, options, callback) {
    var timeout = options.timeout || 2000
      , start = new Date().getTime()
      , interval;

    function iterate() {
      if (condition()) {
        callback();
        clearInterval(interval);
      } else if (new Date().getTime() - start > timeout) {
        try {
          throw (Error('`waitFor()` timeout'));
        } catch (e) {
          console.log(e); // print stack traces would be cool
        }
        phantom.exit(1);
      }
    }

    interval = setInterval(iterate, options.interval || 100);

    return interval;
  }

  /**
   * Shameless copy from Maraks colors.js
   * @param {String} str
   * @param {String} style
   */
  function _colorizer(str, style) {
    var styles = {
      'white'   : 37
    , 'grey'    : 90
    , 'black'   : 90
    , 'blue'    : 34
    , 'cyan'    : 36
    , 'green'   : 32
    , 'magenta' : 35
    , 'red'     : 31
    , 'yellow'  : 33
    };

    return '\033[' + styles[style] + 'm' + str + '\033[39m';
  }

  var _page = new WebPage()
    , _path = 'file://' + phantom.libraryPath;

  // evaluated console logs will output
  _page.onConsoleMessage = function (msg, line, src) {
    if (msg.charAt(0) !== '\033') {
      src = src ? _colorizer(src.split('/').slice(-3).join('/') + ':', 'cyan') : '';
      console.log(src + _colorizer(line + ':', 'cyan') + msg);
    } else {
      console.log(msg);
    }
  };

  function _condition() {
    return _page.evaluate(function () {
      return !!document.body.querySelector('.finished-at');
    });
  }

  console.log(_colorizer('Loading the page...', 'blue'));
  _page.open('file://' + phantom.libraryPath + '/SpecRunner.html', function (status) {
    if (status !== 'success') {
      console.log(_colorizer('Unable to open the file', 'red'));
      phantom.exit();
    } else {
      console.log(_colorizer('Running the tests...', 'yellow'));
      _waitFor(_condition, {}, function () {
        _page.evaluate(function () {
          var suite = document.body.querySelector('div.jasmine_reporter > .suite.failed')
            , description = document.body.querySelector('.description').innerText;

          console.log('\033[' + (suite ? 31 : 32) + 'm' + description + '\033[39m');

          console.log('\033');

          function visitSpec(spec, level) {
            var desc = spec.querySelector('.description')
              , mess = spec.querySelector('.messages').innerText.split('\n').map(function (line) {
                  if (line) {
                    line = line.replace(/file\:\/\/(.*\.js)/, function (str, path) {
                      return path.split('/').slice(-3).join('/');
                    });
                    return Array((level + 1) * 2).join(' ') + '˪ ' + line;
                  } else {
                    return '';
                  }
                }).join('\n');

            console.log('\033[1m\033[31m' + Array(level * 2).join(' ') + '✗ ' + desc.innerText + '\033[22m\033[39m');
            console.log('\033[1m\033[35m' + mess + '\033[22m\033[39m');
          }

          (function visitSuite(suite, level) {
            [].slice.apply(suite.childNodes).forEach(function (child) {
              switch (child.className) {
              case 'description':
                console.log('\033[1m\033[31m' + Array(level * 2).join(' ') + child.innerText + '\033[22m\033[39m');
                break;
              case 'suite failed':
                visitSuite(child, ++level);
                break;
              case 'spec failed':
                visitSpec(child, ++level);
                break;
              }
            });

          }(suite, 0));
        });
        phantom.exit();
      });
    }
  });
}());
