// Request confirmation to close the box
document.on("click", ".video_tutorials_box .hide", function(e,el) {
  el.up('.video_tutorials_box').down('.close_me').show();
  el.hide();
});

document.on("click", ".video_tutorials_box .close_me a", function(e,el) {
  el.up('.video_tutorials_box').fade();
  new Ajax.Request("/account/tutorials/hide");
});
