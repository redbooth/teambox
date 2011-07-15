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

  var page = new WebPage();

  // evaluated console logs will output
  page.onConsoleMessage = function (msg, line, src) {
    if (msg.charAt(0) !== '\033') {
      src = src ? _colorizer(src.split('/').slice(-3).join('/') + ':', 'cyan') : '';
      console.log(src + _colorizer(line + ':', 'cyan') + msg);
    } else {
      console.log(msg);
    }
  };

  function _condition() {
    return page.evaluate(function () {
      return !!document.body.querySelector('.finished-at');
    });
  }

  console.log(_colorizer('Loading the page...', 'blue'));
  page.open('file://' + phantom.libraryPath + '/SpecRunner.html', function (status) {
    if (status !== 'success') {
      console.log(_colorizer('Unable to open the file', 'red'));
      phantom.exit();
    } else {
      console.log(_colorizer('Running the tests...', 'yellow'));
      _waitFor(_condition, {}, function () {
        page.evaluate(function () {
          var list = document.body.querySelectorAll('div.jasmine_reporter div.suite.failed')
            , description = document.body.querySelector('.description').innerText
            , i, el, desc;

          console.log('\033[' + (list.length ? 31 : 32) + 'm' + description + '\033[39m');

          console.log('\033');
          for (i = 0; i < list.length; ++i) {
            el = list[i];
            desc = el.querySelector('.description');
            console.log('\033[31m└─ ' + desc.innerText + '\033[39m');
          }
        });
        phantom.exit();
      });
    }
  });
}());
