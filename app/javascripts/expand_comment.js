contractComments = function() {
  $$('.comment').each(function(comment) {
    if (comment.measure("height") > 500) {
      if (!comment.down(".expand_comment")) {
        comment.down(".block").insert({
          bottom: "<div class='expand_comment'><a href='#'>This comment is too long to be displayed. Click for the full view.</a><span></span></div>"
        });
        comment.down(".block .body").setStyle({
          "height": "500px",
          "overflow-y": "hidden" });
      }
    }
  });
};

document.on("click", ".expand_comment", function(e,el) {
  e.stop();
  el.up(".comment").down(".body").setStyle({ "height": "auto" });
  el.remove();
});

document.on("dom:loaded", function() {
  contractComments();
});
