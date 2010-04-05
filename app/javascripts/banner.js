Banner = {
  deactivate_links: function() {
    $('show_calendar_link').removeClassName("active");
    $('show_gantt_chart_link').removeClassName("active");
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
  "#show_calendar_link:click": function(e){
    Banner.deactivate_links();
    Banner.hide_banner_items();
    Banner.show_banner("upcoming_events_banner");
    Banner.activate_link("show_calendar_link");
  },
  "#show_gantt_chart_link:click": function(e){
    Banner.deactivate_links();
    Banner.hide_banner_items();
    Banner.show_banner("gantt_banner");
    Banner.activate_link("show_gantt_chart_link")
  }
});
