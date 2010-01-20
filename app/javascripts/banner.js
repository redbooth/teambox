Banner = {
  deactivate_links: function() {
    $$(".banner_navigation a").each(function(link){
      link.removeClassName("active");
    })
  },
  activate_link: function(link_id) {
    $(link_id).addClassName("active");
  },
  hide_banner_items: function() {
    $$(".banner_item").invoke("hide");
  },
  show_banner: function(banner_id) {
    $(banner_id).show();
  }

}

Event.addBehavior({
  ".banner_navigation li.calendar:click": function(e){
    // $$(".banner_navigation a").invoke("removeClassName", "active");
    Banner.deactivate_links();
    Banner.hide_banner_items();
    Banner.show_banner("upcoming_events_banner");
    Banner.activate_link("calendar_banner_link")
  },
  ".banner_navigation li.gantt_chart:click": function(e){
    // $$(".banner_navigation a").invoke("removeClassName", "active");
    Banner.deactivate_links();
    Banner.hide_banner_items();
    Banner.show_banner("gantt_banner");
    Banner.activate_link("gantt_banner_link")
  }
});
