document.on("dom:loaded", function() {
  if (window.location.hash === '') {
    window.location.hash = '#!/';
  }
  // Fetch current user
  Teambox.my_user = new Teambox.Models.User();
  Teambox.my_user.fetch();

  // Fetch my tasks
  Teambox.my_tasks = new Teambox.Collections.Tasks();
  Teambox.my_tasks.fetch();

  // Print my tasks
  Teambox.my_tasks_counter_view = new Teambox.Views.MyTasksCounter({
    collection: Teambox.my_tasks
  });
  Teambox.my_tasks_view = new Teambox.Views.MyTasks({
    collection: Teambox.my_tasks
  });

  app = new Teambox.Controllers.AppController();
  Backbone.history.start();
});

