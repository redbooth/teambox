/*globals Templates*/
(function () {
  var MyTasks = { title: "Tasks assigned to you"
                , template: Handlebars.compile(Templates.tasks.index)
                , primer_template: Handlebars.compile(Templates.primers.today)
                };

  MyTasks.initialize = function (options) {
    _.bindAll(this, 'render');
  };

  MyTasks.render = function () {
    Teambox.helpers.tasks.render({ tasks: this.collection.mine()
                                 , title: this.title
                                 , template: this.template
                                 , primer_template: this.primer_template });
  };

  // expose
  Teambox.Views.MyTasks = Backbone.View.extend(MyTasks);

}());

