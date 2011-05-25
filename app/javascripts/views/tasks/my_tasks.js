/*globals Templates*/
(function () {
  var MyTasks = { title: "Tasks assigned to you"
                , template: Handlebars.compile(Templates.tasks.index)
                , primer_template: Handlebars.compile(Templates.primers.today)
                }
    , TasksHelper = Teambox.helpers.tasks;

  MyTasks.initialize = function (options) {
    _.bindAll(this, 'render');
  };

  MyTasks.render = function () {
    TasksHelper.render({ tasks: this.collection.mine()
                       , title: this.title
                       , template: this.template
                       , primer_template: this.primer_template });

    TasksHelper.group({ tasks: $$('#content .task')
                      , where: $$('#content .tasks')[0]
                      , by: 'due_date' });
  };

  // expose
  Teambox.Views.MyTasks = Backbone.View.extend(MyTasks);

}());

