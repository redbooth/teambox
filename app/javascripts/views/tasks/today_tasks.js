(function () {
  var TodayTasks = { title: "Your Tasks for today"
                   , template: Handlebars.compile("<h2>What you need to do today</h2>" + Templates.tasks.index)
                   , primer_template: Handlebars.compile(Templates.primers.today)
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
