# Used to switch tabs between the Gantt charts and Calendar

Banner =
  deactivate_tabs: ->
    $('tab_calendar').removeClassName("active")
    $('tab_gantt').removeClassName("active")
  activate_tab: (tab_id) ->
    $(tab_id).addClassName("active")
  hide_banner_items: ->
    $$(".banner_item").invoke("hide")
  show_banner: (banner_id) ->
    $(banner_id).show()

document.on 'click', '#show_calendar_link', (e,el) ->
  e.stop()
  Banner.deactivate_tabs()
  Banner.hide_banner_items()
  Banner.show_banner("upcoming_events_banner")
  Banner.activate_tab("tab_calendar")

document.on 'click', '#show_gantt_chart_link', (e,el) ->
  e.stop()
  Banner.deactivate_tabs()
  Banner.hide_banner_items()
  Banner.show_banner("gantt_banner")
  Banner.activate_tab("tab_gantt")
