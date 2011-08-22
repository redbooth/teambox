ActivityFeed = {
  collapseAll: function() {
    var activities = jQuery('#activities');
    if (activities) {
      jQuery('#activities .activity, #activities .thread').addClass("collapsed");
      activities.addClass("collapsed");
      this.collapsed = true;
    }
  },
  expandAll: function() {
    var activities = jQuery('#activities');
    if (activities) {
      jQuery('#activities .activity, #activities .thread').removeClass("collapsed");
      activities.removeClass("collapsed");
      this.collapsed = false;
    }
  },
  toggle: function(el) {
    el.toggleClass("collapsed");
    Threads.select(el);
    Threads.ensureVisible(el);
  },
  collapsed: false
};

document.on("click", "a.collapsed_mode", function(e,el) {
  e.preventDefault();
  ActivityFeed.collapseAll();
  jQuery('a.collapsed_mode, a.expanded_mode').parent('.el').toggle();
  var r = new Ajax.Request('/account/activity_feed_mode/collapsed');
});

document.on("click", "a.expanded_mode", function(e,el) {
  e.preventDefault();
  ActivityFeed.expandAll();
  jQuery('a.collapsed_mode, a.expanded_mode').parent('.el').toggle();
  var r = new Ajax.Request('/account/activity_feed_mode/expanded');
});

document.on("click", "#activities .comment_header", function(e,el) {
  ActivityFeed.toggle(jQuery(el).parent('.thread'));
});

document.on("click", "#activities .comment_header a", function(e,el) {
  ActivityFeed.toggle(jQuery(el).parent('.thread'));
  if (e.isMiddleClick()) { return; }
  if (jQuery(el).parent('.project_overlay').length === 0) {
    e.preventDefault();
    window.location = jQuery(el).attr("href");
  }
});

document.on("dom:loaded", function() {
  if (my_user.collapse_activities && jQuery('a.collapsed_mode').length !== 0) {
    ActivityFeed.collapseAll();
    jQuery('a.collapsed_mode, a.expanded_mode').parent('.el').toggle();
  }
});

