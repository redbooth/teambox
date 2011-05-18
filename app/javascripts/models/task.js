(function () {
  var _one_day = 1000 * 60 * 60 * 24;

  Teambox.Models.Task = Backbone.Model.extend({
    initialize: function () {
    }

  , overdue: function () {
      return new Date() - this.get('due_on');
    }

  , is_overdue: function () {
      return !this.get('archived?') && this.get('due_on') && new Date() > this.get('due_on');
    }

  , is_due_today: function () {
      return this.get('due_on') === new Date();
    }

  , is_due_tomorrow: function () {
      return this.get('due_on') === new Date() + _one_day;
    }

  , is_due_in: function (time_end) {
      return this.get('due_on')
          && this.get('due_on') >= new Date()
          && this.get('due_on') < (new Date() + time_end);
    }

  , url: function () {
      return "/api/1/tasks/" + this.get('id');
    }
  });

}());
