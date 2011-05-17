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

    // init()
    _body.addClassName('loading');
    _loading_bar.setStyle({width: "10px"});

    /* Get a callback to handle parallel requests and updates a loading_bar
     *
     * @param {String} req
     * @return {Function}
     */
    LOADER.load = function (req) {

      LOADER.total += 1;

      return function () {
        LOADER.loaded += 1;

        if (LOADER.loaded === LOADER.total) {
          _body.toggleClassName('loading');
          if (callback) {
            console.log('FLEIBA');
            return callback();
          }
        } else {
          var width = 200 * LOADER.loaded / (LOADER.total - 1);
          _loading_bar.setStyle({width: width + "px"});
        }
      };
    };

    return LOADER;
  };
}());
