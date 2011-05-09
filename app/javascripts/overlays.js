// Keeps track of open overlay panes
Overlays = {
  open_overlays: [],
  open: function(el, overlay) {
    this.closeAll();
    el.insert({ bottom: overlay });
    this.open_overlays.push(el.down('.overlay'));
  },
  closeAll: function() {
    this.open_overlays.invoke('remove');
    this.open_overlays = [];
  }
};


// When you click on a div.project_overlay containing a link, display the overlay
document.on("click", ".project_overlay a", function(e,el) {
  var project = my_projects[el.readAttribute('data-project-id')];
  if (project) {
    e.stop();
    Overlays.open(
      el.up('.project_overlay'),
      Mustache.to_html(Templates.projects.overlay, { project: project }));
  }
});

// If you click anywhere else, hide all overlays
document.on("click", function(e,el) {
  if (el.up('.project_overlay')) { return; }
  Overlays.closeAll();
});
