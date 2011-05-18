/*globals Templates*/
(function () {
  var Tasks = {};

  Tasks.render = function (options) {
    $('view_title').update(options.title);
    if (options.tasks.length > 0) {
      $('content').update(options.template());
      options.tasks.each(function (task) {
        var view = new Teambox.Views.Task({ model: task });
        //TODO: render tasks on a document fragment and insert it only once to avoid reflow
        $$('.task_list .tasks')[0].insert({ bottom: view.render().el });
      });
    } else {
      $('content').update(options.primer_template());
    }
  };

  // expose
  Teambox.helpers.tasks = Tasks;

}());
