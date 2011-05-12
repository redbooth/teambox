var Teambox = {
  Models: {},
  Collections: {},
  Controllers: {},
  Views: {}
}, $app;

document.on("dom:loaded", function () {
  $app = Teambox.application = new Teambox.Controllers.AppController();
});
