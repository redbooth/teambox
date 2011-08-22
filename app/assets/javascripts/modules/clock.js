//
// The Great Synchronization Clock
//
// https://github.com/cloudhead/thingler/blob/master/pub/js/thingler.js#L114

(function () {

  var Clock = {
      timer: null,
      interval: 1000 * 60 * 5,
      synchronising: true,
      init: function (callback) {
          this.callback = callback;
          this.reset(this.interval);
      },
      //
      // Creates a new timer based the interval
      // passed.
      //
      reset: function (interval) {
          // One hour maximum interval
          this.interval = Math.min(interval, 3600000);

          if (this.timer)   { clearInterval(this.timer) }
          if (this.timeout) { clearTimeout(this.timeout) }

          this.timer = setInterval(function () {
              Clock.tick();
          }, this.interval);

          // In `this.interval * 4` milliseconds,
          // double the interval.
          // Note that this could never happen,
          // if a `reset` is executed within that time.
          this.timeout = setTimeout(function () {
              Clock.reset(Clock.interval * 2);
          }, this.interval * 4);
      },
      //
      // Called on every interval tick.
      //
      tick: function (arg) {
          if (! this.synchronising) {
              this.synchronising = true;
              this.callback(this, arg);
          }
      },

      //Call this to renable executing tick callback
      synchronised: function () {
          this.synchronising = false;
      },

      //Call this to disable executing tick callback
      synchronise: function () {
         this.synchronising = true;
      },
 
      //
      // Called on inbound & outbound activity.
      // We either preserve the current interval length,
      // if it's the shortest possible, or divide it by four.
      //
      activity: function () {
          if (this.interval < 4000) {
              this.reset(1000);
          } else {
              this.reset(this.interval / 4);
          }
          return true;
      }
  };

  //exports
  Teambox.modules.Clock = Clock;
}());

