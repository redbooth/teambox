(function () {
  var AllTasks = { title: 'All tasks in your projects'
                 , template: Teambox.modules.ViewCompiler('tasks.index')
                 , primer_template: Teambox.modules.ViewCompiler('primers.all_tasks')
                 }
    , TasksHelper = Teambox.helpers.tasks;

  AllTasks.initialize = function (options) {
    _.bindAll(this, 'render');

    ['change', 'add', 'remove'].each(function (event) {
      this.collection.unbind(event);
      this.collection.bind(event, this.render);
    }.bind(this));
  };

  /**
   * Updates the element
   *
   * @return this
   */
  AllTasks.render = function () {
    TasksHelper.render.call(this, { tasks: this.collection
                                  , template: this.template
                                  , primer_template: this.primer_template });

    TasksHelper.group({ tasks: this.el.select('.task')
                      , where: this.el.select('.tasks')[0]
                      , by: 'assigned' });

    return this;
  };

  // expose
  Teambox.Views.AllTasks = Backbone.View.extend(AllTasks);

}());
