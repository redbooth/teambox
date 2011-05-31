(function () {
  var AllTasks = { title: "All tasks in your projects"
                 , template: Handlebars.compile(Templates.tasks.index)
                 , primer_template: Handlebars.compile(Templates.primers.all_tasks)
                 }
    , TasksHelper = Teambox.helpers.tasks;

  AllTasks.initialize = function (options) {
    _.bindAll(this, 'render');
  };

  AllTasks.render = function () {
    var filters = new Teambox.Views.Filters({ task_list: this
                                            , filters: { name: null
                                                       , assigned: null
                                                       , due_date: null
                                                       , status: null }});

    TasksHelper.render({ tasks: this.collection
                       , title: this.title
                       , template: this.template
                       , primer_template: this.primer_template });

    TasksHelper.group({ tasks: $$('#content .task')
                      , where: $$('#content .tasks')[0]
                      , by: 'assigned' });

    // add filters
    $('content').insert({top: filters.render().el});
  };

  // expose
  Teambox.Views.AllTasks = Backbone.View.extend(AllTasks);

}());
