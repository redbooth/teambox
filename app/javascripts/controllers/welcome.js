(function () {
  var WelcomeController = { routes: { '!/welcome'     : 'intro' } };

  var Views = Teambox.Views;

  WelcomeController.intro = function() {
    Views.Sidebar.highlightSidebar('welcome_link');
    //$('content').update(Templates.welcome.intro);
    var view = new Teambox.Views.Welcome();
    $('content').update(view.render().el);
    $('view_title').update("Welcome");
  }


  // exports
  Teambox.Controllers.WelcomeController = Teambox.Controllers.BaseController.extend(WelcomeController);
}());

