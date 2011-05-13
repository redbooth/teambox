var Teambox = {
  Models: {}
, Collections: {}
, Controllers: {}
, Views: {}
, modules: {}
}, $app;

document.on("dom:loaded", function () {
  $app = Teambox.application = new Teambox.Controllers.AppController();
});
