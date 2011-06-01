(function () {
  var SelectStatus = { tagName: 'select'
                     , className: 'task_status'
                     }
    , TasksModel = Teambox.Models.Task;

  SelectStatus.initialize = function (options) {
    _.bindAll(this, 'render');
    this.selected = options.selected;
  };

  SelectStatus.render = function () {
    var el = this.el
      , self = this;

    el.update(_.reduce(TasksModel.status.status, function (memo, stat) {
      memo += '<option value="' + stat.value + '"' + (self.selected === stat.value ? ' selected="selected"' : '') + '>';
      memo += stat.label + '</option>';
      return memo;
    }, ''));
  };

  // expose
  Teambox.Views.SelectStatus = Backbone.View.extend(SelectStatus);

}());
