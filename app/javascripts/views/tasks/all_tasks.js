/*globals Templates*/
(function () {
  var AllTasks = { title: "All tasks in your projects"
                 , template: Handlebars.compile(Templates.tasks.all_tasks)
                 , primer_template: Handlebars.compile(Templates.primers.all_tasks)
                 };

  AllTasks.initialize = function (options) {
    _.bindAll(this, 'render');
  };

  AllTasks.render = function () {
    Teambox.helpers.tasks.render({ tasks: this.collection
                                 , title: this.title
                                 , template: this.template
                                 , primer_template: this.primer_template });
  };

  // expose
  Teambox.Views.AllTasks = Backbone.View.extend(AllTasks);

}());
