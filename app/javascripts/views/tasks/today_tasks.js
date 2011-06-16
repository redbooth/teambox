(function () {
  var TodayTasks = { title: "Your Tasks for today"
                   , template: Teambox.modules.ViewCompiler('tasks.index')
                   , primer_template: Teambox.modules.ViewCompiler('primers.today')
                   }
    , TasksHelper = Teambox.helpers.tasks;

  TodayTasks.initialize = function (options) {
    _.bindAll(this, 'render');
    ['change','add','remove'].each(function(event) {
      this.collection.unbind(event);
      this.collection.bind(event, this.render);
    }.bind(this));

  };

  TodayTasks.render = function () {
    TasksHelper.render({ tasks: this.collection.today()
                       , title: this.title
                       , template: this.template
                       , primer_template: this.primer_template });
  };

  // expose
  Teambox.Views.TodayTasks = Backbone.View.extend(TodayTasks);

}());
