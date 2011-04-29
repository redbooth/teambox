// Loader is a utility class that counts which requests have
// been sent and which have been completed, updating a progress bar.
// 
// Loader.loaded('requestname') will register the request we send
// and return a function to be used as a callback on success.

Loader = {
  steps: { loaded: [], total: [] },
  init: function(onAllStepsLoaded) {
    $$('body')[0].addClassName('loading');
    this.steps = { loaded: [], total: [] };
    $$('.loading .bar .fill')[0].setStyle({width: "10px"});
    this.onAllStepsLoaded = onAllStepsLoaded;
  },
  loaded: function(req) {
    Loader.steps.total.push(req);
    return function(req) {
      Loader.steps.loaded.push(req);
      if(Loader.steps.loaded.length == Loader.steps.total.length) {
        $$('body')[0].toggleClassName('loading');
        if (Loader.onAllStepsLoaded) Loader.onAllStepsLoaded();
      } else {
        var width = 200 * Loader.steps.loaded.length / (Loader.steps.total.length - 1);
        $$('.loading .bar .fill')[0].setStyle({width: width+"px"});
      }
    };
  }
};
