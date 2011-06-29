// Loader is a utility class that counts which requests have
// been sent and which have been completed, updating a progress bar.
//
// Loader.loaded('requestname') will register the request we send
// and return a function to be used as a callback on success.

(function () {

  Teambox.modules.Loader = function (callback) {
    var LOADER = {loaded: 0, total: 0}
      , _body = $$('body')[0]
      , _loading_bar = $$('.loading .bar .fill')[0];

    callback = callback || function () {}; // noop
    _body.addClassName('loading');
    _loading_bar.setStyle({width: '0px'});

    /* Curries a callback to handle parallel requests and update a loading_bar
     *
     * @param {Function} cb
     * @return {Function}
     */
    LOADER.load = function (cb) {

      LOADER.total++;
      cb = cb || function () {}; // noop

      return function () {
        cb.apply(cb, arguments);
        if (++LOADER.loaded === LOADER.total) {
          _body.toggleClassName('loading');
          return callback();
        } else {
          var width = 130 * LOADER.loaded / LOADER.total;
          _loading_bar.setStyle({width: width + "px"});
        }
      };
    };

    return LOADER;
  };
}());
