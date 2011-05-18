var Teambox = {};
_.each(['Models', 'Collections', 'Controllers', 'Views'            // Constructors
      , 'collections', 'controllers', 'models', 'views', 'helpers' // Instances
      , 'modules', 'cache'], function (el) {                       // other
  Teambox[el] = {};
});

document.on("dom:loaded", function () {
  Teambox.controllers.application = new Teambox.Controllers.AppController();
});
