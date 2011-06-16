(function () {
  var MyTasks = { title: "Tasks assigned to you"
                , template: Teambox.modules.ViewCompiler('tasks.index')
                , primer_template: Teambox.modules.ViewCompiler('primers.my_tasks')
                }
    , TasksHelper = Teambox.helpers.tasks;

  MyTasks.initialize = function (options) {
    _.bindAll(this, 'render');

    ['change','add','remove'].each(function(event) {
      this.collection.unbind(event);
      this.collection.bind(event, this.render);
    }.bind(this));

  };

  /* updates the element
   *
   * @return self
   */
  MyTasks.render = function () {
    TasksHelper.render.call(this, { tasks: this.collection.mine()
                                  , title: this.title
                                  , template: this.template
                                  , primer_template: this.primer_template });

    TasksHelper.group({ tasks: $$('#content .task')
                      , where: $$('#content .tasks')[0]
                      , by: 'due_date' });

    return this;
  };

  // expose
  Teambox.Views.MyTasks = Backbone.View.extend(MyTasks);

}());
