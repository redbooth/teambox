Filter = {
  showAllTaskLists: function() {
    $$(".task_list_container").each(function(e){ e.show() })
  },
  showAllTasks: function() {
    $$("table.task_list tr.task").each(function(e){ e.show() })
    $$("table.task_list_closed tr.task").each(function(e){ e.show() })
  },
  hideAllTasks: function() {
    $$("table.task_list tr.task").each(function(e){ e.hide() })
    $$("table.task_list_closed tr.task").each(function(e){ e.hide() })
  },
  showTasks: function(by) {
    $$("table.task_list tr." + by).each(function(e){ e.show() })
  },
  hideTasks: function(by) {
    $$("table.task_list tr." + by).each(function(e){ e.hide() })
  },
  // Hides task lists if they don't have any visible tasks
  foldEmptyTaskLists: function() {
    $$("table.task_list").each(function(e) {
      visible_tasks = e.select("tr.task").reject( function(e) {
        return e.getStyle("display") == "none"
      })
      if(visible_tasks.length == 0) {
        e.up('.task_list_container').hide();
      }
    })
  }
}

Event.addBehavior({
  "#filter_assigned:change": function(){
    $("filter_due_date")[0].selected = "selected"
    Filter.showAllTaskLists();
    switch($(this).value) {
      case "all":
        Filter.showAllTasks()
      break
      case "mine":
        Filter.hideAllTasks()
        Filter.showTasks('mine')
        Filter.foldEmptyTaskLists()
      break
      // For 'unassigned' and 'user_xx'
      default:
        Filter.hideAllTasks()
        Filter.showTasks($(this).value)
        Filter.foldEmptyTaskLists()
      break
    }
  }
})

Event.addBehavior({
  "#filter_due_date:change": function(){
    $("filter_assigned")[0].selected = "selected"
    Filter.showAllTaskLists();
    switch($(this).value) {
      case "all":
        Filter.showAllTasks()
      break
      case "mine":
        Filter.hideAllTasks()
        Filter.showTasks('mine')
        Filter.foldEmptyTaskLists()
      break
      // For 'unassigned' and 'user_xx'
      default:
        Filter.hideAllTasks()
        Filter.showTasks($(this).value)
        Filter.foldEmptyTaskLists()
      break
    }
  }
})