// Highlight backboned links on the sidebar
document.on("click", ".nav_links a.backboned", function(e,a) {
  var el = a.up('.el');
  if(!a.hasClassName('backboned')) { return; }
  NavigationBar.selectElement(el);
});

document.on("dom:loaded", function() {
  Teambox.init();
});

