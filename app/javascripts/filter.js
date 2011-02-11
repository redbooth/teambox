Filter = {
  assigned_options: null,
  count_due_date: null,
  
  init: function() {
    var filter_assigned = $("filter_assigned")
    var filter_due_date = $("filter_due_date")
    var filter_tasks_by_name = $('filter_tasks_by_name')

    if (params("filter_assigned"))      filter_assigned.value      = params("filter_assigned")
    if (params("filter_due_date"))      filter_due_date.value      = params("filter_due_date")
    if (params("filter_tasks_by_name")) filter_tasks_by_name.value = params("filter_tasks_by_name")

    if (filter_assigned) Filter.assigned_options = Filter.initOptions(filter_assigned.options)
    if (filter_due_date) Filter.count_due_date = Filter.mapOptions(filter_due_date.options)
  },
  
  showAllTaskLists: function() {
    $$(".task_list_container").invoke('show')
  },
  showAllTasks: function() {
    $$(".tasks div.task").invoke('show')
    $$(".tasks.closed div.task").invoke('show')
  },
  hideAllTasks: function() {
    $$(".tasks div.task").invoke('hide')
    $$(".tasks.closed div.task").invoke('hide')
  },
  showTasks: function(by, filter) {
    $$(".tasks div.task."+by).each(function(e){
      if (filter == null || e.hasClassName(filter))
        e.show();
      else
        e.hide();
    });
  },
  countTasks: function(by, date_filter) {
    return $$(".tasks div.task." + by).select(function(e){
      return (date_filter == null || e.hasClassName(date_filter))
    }).length
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
  
  initOptions: function(assigned_options) {
    var out = [];
    len = assigned_options.length;
    for (var i=0; i<len; i++) {
        var option = assigned_options[i];
        out.push({value:option.value, text:option.text, disabled:option.disabled, count:0});
    };
    return out;
  },
  
  mapOptions: function(options) {
      var out = [];
      var len = options.length;
      for (var i=0; i<len; i++)
        out.push(options[i].text);
      return out;
  },
  
  updateFilters: function() {
    if (Filter.assigned_options == null && Filter.count_due_date == null)
      Filter.init();
    
    var el_name = $("filter_tasks_by_name")
    var el = $("filter_assigned");
    var el_filter = $("filter_due_date");
    if (el == null && el_filter == null) return;

    var name_match = el_name.value
    var assigned = el.value == 'all' ? 'task' : el.value;
    var filter = el_filter.value == 'all' ? null : el_filter.value;

    Filter.showAllTaskLists();
    Filter.hideAllTasks();

    if ((name_match == "" || name_match == el_name.readAttribute('placeholder')) && assigned == 'task' && filter == null)
    {
      Filter.showAllTasks();
    } else {
      Filter.showTasks(assigned, filter);
      if (name_match!=el_name.readAttribute("placeholder")) Filter.hideBySearchBox(name_match);
      Filter.foldEmptyTaskLists();
    }

    Filter.updateCounts(true);
  },
  
  hideBySearchBox: function(matchText) {
    matchText = matchText.toLowerCase()
    $$(".tasks div.task").each(function(t){
      if(!t.down('a.name').innerHTML.toLowerCase().match(matchText))
        t.hide()
    });
  },

  updateCounts: function(due_only) {
    if (Filter.assigned_options == null && Filter.count_due_date == null)
      Filter.init();

    var el = $("filter_assigned");
    var el_filter = $("filter_due_date");
    if (el == null)
      return;
    
    var current_assigned = el.value;
    var assigned = el.value == 'all' ? 'task' : el.value;
    var count_due_date = Filter.count_due_date;
    var assigned_options = Filter.assigned_options;
    var len;
    
    if (!due_only) 
    {
      el.options.length = 0;
      len = assigned_options.length;
      var idx = 0;
      for (var i=0; i<len; i++)
      {
        var option = assigned_options[i];
        if (option.disabled) {
            el.options[idx] = new Option(option.text, option.value);
            el.options[idx].disabled = true;
            idx += 1;
        } else {
            var filter = option.value == 'all' ? 'task' : option.value;
            var count = Filter.countTasks(filter, null);
            if (i < 3 || count > 0 || filter == current_assigned) {
                el.options[idx] = (new Option(option.text + ' (' + count + ')', option.value));
                idx += 1;
            }
        }
      }
      el.value = current_assigned;
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
  },

  populatePeopleForTaskFilter: function() {
    if ((typeof _people == "object") && (select = $('filter_assigned'))) {
      select.insert(new Element('option', { 'value': 'divider', 'disabled': true}).insert('--------'))
      var users = []
      var user_ids = []
      if (project_id = select.readAttribute('data-project-id') && project_id != 0) {
        users = _people[project_id].collect(function (e) { return [e[3],e[2]] })
      }
      else {
        (new Hash(_people)).values().each(function (project) {
          project.each(function(person) {
            if (!user_ids.include(person[3])) {
              users.push([person[3],person[2]])
              user_ids.push(person[3])
            }
          })
        })
      }
      users.sortBy(function(e) { return e[1] }).each(function(user) {
        var option = new Element('option', { 'value': 'user_' + user[0]}).insert(user[1])
        select.insert(option)
      })
    }
  }

};

document.on('keyup', '#filter_tasks_by_name', function(evt,el) {
  Filter.updateFilters();
}.throttle(200)) // throttling the function improves performance

// handles the "clear searchbox" event for webkit
document.on('click', '#filter_tasks_by_name', function(evt,el) {
  Filter.updateFilters();
})

document.on("change", "#filter_tasks_by_name, #filter_assigned, #filter_due_date", function(evt, el){
  Filter.updateFilters()
  print_link = $$('.print_link').first()
  print_link.href = 	window.location.href + '.print?filter_assigned=' + $('filter_assigned').value + '&filter_due_date=' + $('filter_due_date').value + '&filter_tasks_by_name='  + $('filter_tasks_by_name').value
});
