Filter = {
  showAllTaskLists: function() {
    $$(".task_list_container").each(function(e){ e.show() })
  },
  showAllTasks: function() {
    $$(".tasks div.task").each(function(e){ e.show() });
    $$(".tasks.closed div.task").each(function(e){ e.show() });
  },
  hideAllTasks: function() {
    $$(".tasks div.task").each(function(e){ e.hide() });
    $$(".tasks.closed div.task").each(function(e){ e.hide() });
  },
  showTasks: function(by, filter) {
    $$(".tasks.open div." + by).each(function(e){
      if (filter == null || e.hasClassName(filter))
        e.show();
      else
        e.hide();
    });
  },
  hideTasks: function(by, filter) {
    $$("table.task_list div.task" + by).each(function(e){
      if (filter == null || e.hasClassName(filter))
        e.hide();
      else
        e.show();
    });
  },
  // Hides task lists if they don't have any visible tasks
  foldEmptyTaskLists: function() {
    $$("div.task_list").each(function(e) {
      var container = e.up('.task_list_container');
      if (container.hasClassName('archived'))
      {
        container.hide();
        return;
      }

      visible_tasks = e.select(".task").reject( function(e) {
        return e.getStyle("display") == "none";
      })
      if(visible_tasks.length == 0) {
        container.hide();
      }
    })
  },

  updateFilters: function() {
    var el = $("filter_assigned");
    var el_filter = $("filter_due_date");

    var assigned = el.value == 'all' ? 'task' : el.value;
    var filter = el_filter.value == 'all' ? null : el_filter.value;

    //console.log("FILTER:" + assigned + "," + filter);
    
    Filter.showAllTaskLists();
    Filter.hideAllTasks();

    if (assigned == 'task' && filter == null) {
      Filter.showAllTasks();
    }
    else
    {
      Filter.showTasks(assigned, filter);
      Filter.foldEmptyTaskLists();
    }
  }
};

document.on("change", "#filter_assigned", function(evt, el){
  Filter.updateFilters();
});

document.on("change", "#filter_due_date", function(evt, el){
  Filter.updateFilters();
});
