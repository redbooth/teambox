(function () {
  var SelectAssigned = { tagName: 'select'
                       , className: 'task_assigned_id'
                       };

  SelectAssigned.initialize = function (options) {
    _.bindAll(this, 'render');

    this.project = options.project;
    this.selected = options.selected;
  };

  SelectAssigned.render = function () {
    var users = _.sortBy(_.map(this.project.get('people').models, function (person) {
          return person.get('user');
        }), function (user) {
          return user.first_name;
        })
      , _default = '<option ' + (!this.selected ? ' selected="selected"' : '') + '>Unassigned</option>'
      , self = this;

    this.el.update(_default + _.reduce(users, function (memo, user) {
      memo += '<option value="' + user.id + '"';
      memo += (self.selected === user.id ? ' selected="selected"' : '') + '>';
      memo += user.first_name + ' ' + user.last_name + '</option>';
      return memo;
    }, ''));
  };

  // expose
  Teambox.Views.SelectAssigned = Backbone.View.extend(SelectAssigned);

}());
