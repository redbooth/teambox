(function () {
  var ProjectTasks = { title: 'Tasks'
                     , template: Teambox.modules.ViewCompiler('tasks.index')
                     , primer_template: Teambox.modules.ViewCompiler('primers.my_tasks')
                     }
    , TasksHelper = Teambox.helpers.tasks;

  ProjectTasks.initialize = function (options) {
    _.bindAll(this, 'render');

    ['change', 'add', 'remove'].each(function (event) {
      this.collection.unbind(event);
      this.collection.bind(event, this.render);
    }.bind(this));

  };

  /* updates the element
   *
   * @return self
   */
  ProjectTasks.render = function () {
    TasksHelper.render.call(this, { tasks: this.collection.models
                                  , title: this.title
                                  , template: this.template
                                  , primer_template: this.primer_template });

    TasksHelper.group({ tasks: $$('#content .task')
                      , where: $$('#content .tasks')[0]
                      , by: 'due_date' });

    return this;
  };

  // expose
  Teambox.Views.ProjectTasks = Backbone.View.extend(ProjectTasks);

}());
