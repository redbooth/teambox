Filter = {
  count_assigned: null,
  count_due_date: null,
  
  init: function() {
    Filter.count_assigned = Filter.mapOptions($("filter_assigned").options);
    Filter.count_due_date = Filter.mapOptions($("filter_due_date").options);
  },

  mapOptions: function(options) {
    var out = [];
    var len = options.length;
    for (var i=0; i<len; i++)
      out.push(options[i].text);
    return out;
  },
  
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
  countTasks: function(by, filter) {
    var count = 0;
    $$(".tasks.open div." + by).each(function(e){
      if (filter == null || e.hasClassName(filter))
        count += 1;
    });
    return count;
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

    if (assigned == 'task' && filter == null) 
    {
      Filter.showAllTasks();
    }
    else
    {
      Filter.showTasks(assigned, filter);
      Filter.foldEmptyTaskLists();
    }

    Filter.updateCounts(true);
  },

  updateCounts: function(due_only) {
    if (Filter.count_assigned == null)
      Filter.init();

    var el = $("filter_assigned");
    var el_filter = $("filter_due_date");
    
    var assigned = el.value == 'all' ? 'task' : el.value;
    var count_assigned = Filter.count_assigned;
    var count_due_date = Filter.count_due_date;

    var len;
    if (!due_only) 
    {
      len = el.options.length;
      for (var i=0; i<len; i++)
      {
        var option = el.options[i];
        if (option.disabled)
          continue;
        var filter = option.value == 'all' ? 'task' : option.value;
        option.text = count_assigned[i] + ' (' + Filter.countTasks(filter, null) + ')';
      }
    }

    len = el_filter.options.length;
    for (var i=0; i<len; i++)
    {
      var option = el_filter.options[i];
      if (option.disabled)
        continue;
      var filter = option.value == 'all' ? null : option.value;
      option.text = count_due_date[i] + ' (' + Filter.countTasks(assigned, filter) + ')';
    }
  }
};

document.on("change", "#filter_assigned", function(evt, el){
  Filter.updateFilters();
});

document.on("change", "#filter_due_date", function(evt, el){
  Filter.updateFilters();
});

document.on('dom:loaded', function() {
  Filter.updateCounts(false);
});
