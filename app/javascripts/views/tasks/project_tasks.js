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
    console.log(this.collection.models);
    TasksHelper.render.call(this, { tasks: this.collection.models
                                  , title: this.title
                                  , template: this.template
                                  , dragndrop: true
                                  , primer_template: this.primer_template });

    TasksHelper.group({ tasks: this.el.select('.task')
                      , where: this.el.down('.tasks')
                      , by: 'task_list' });

    return this;
  };

  // expose
  Teambox.Views.ProjectTasks = Backbone.View.extend(ProjectTasks);

}());
