/*globals WebPage, phantom*/

(function () {

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

  var _page = new WebPage();

  // evaluated console logs will output
  _page.onConsoleMessage = function (msg, line, src) {
    if (msg.charAt(0) !== '\033') {
      src = src ? _colorizer(src.split('/').slice(-3).join('/') + ':', 'cyan') : '';
      console.log(src + _colorizer(line + ':', 'cyan') + msg);
    } else {
      console.log(msg);
    }
  };

  console.log(_colorizer('Loading the page...', 'blue'));
  _page.open('http://localhost:3000/', function (status) {
    if (status !== 'success') {
      console.log(_colorizer('Unable to open the file', 'red'));
      phantom.exit();
    } else {
      console.log(_colorizer('Running the tests...', 'yellow'));
      _page.injectJs('/integration/include.js'); // include assertion lib
      phantom.injectJs('/integration/tests.js'); // include assertion lib
      _tests.forEach(function (test) {
        _page.injectJs('/integration/tests/' + test + '.js'); // include assertion lib
      });
      phantom.exit();
    }
  });
}());

