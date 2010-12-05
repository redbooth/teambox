window.Filter =
  assigned_options: null
  count_due_date: null
  
  init: ->
    filter_assigned = $("filter_assigned")
    filter_due_date = $("filter_due_date")
    filter_tasks_by_name = $('filter_tasks_by_name')

    filter_assigned.value = params("filter_assigned") if params("filter_assigned")
    filter_due_date.value = params("filter_due_date") if params("filter_due_date")
    filter_tasks_by_name.value = params("filter_tasks_by_name") if params("filter_tasks_by_name")

    @assigned_options = @initOptions(filter_assigned.options) if (filter_assigned)
    @count_due_date = @mapOptions(filter_due_date.options) if (filter_due_date)
  
  showAllTaskLists: ->
    $$(".task_list_container").invoke('show')

  showAllTasks: ->
    $$(".tasks div.task").invoke('show')
    $$(".tasks.closed div.task").invoke('show')

  hideAllTasks: ->
    $$(".tasks div.task").invoke('hide')
    $$(".tasks.closed div.task").invoke('hide')

  showTasks: (selector, filter) ->
    $$("div.task."+selector).each (e) ->
      if filter == null || e.hasClassName(filter)
        e.show()
      else
        e.hide()

  countTasks: (selector, date_filter) ->
    tasks = $$("div.task." + selector).select (e) ->
      (date_filter == null or e.hasClassName(date_filter))
    tasks.length

  hideTasks: (selector, filter) ->
    $$("table.task_list div.task" + selector).each (e) ->
      if filter == null || e.hasClassName(filter)
        e.hide()
      else
        e.show()

  # Hides task lists if they don't have any visible tasks
  foldEmptyTaskLists: ->
    $$("div.task_list").each (e) ->
      container = e.up('.task_list_container')
      if container.hasClassName('archived')
        container.hide()
        return

      visible_tasks = e.select(".task").reject (e) ->
        return e.getStyle("display") == "none"

      if visible_tasks.length == 0
        container.hide()

  initOptions: (assigned_options) ->
    out = []
    for option in assigned_options
      out.push value: option.value, text: option.text, disabled: option.disabled, count: 0
    out

  mapOptions: (options) ->
      out = []
      for option in options
        out.push option.text
      out
  
  updateFilters: ->
    if !@assigned_options? && !@count_due_date
      @init()
    
    el_name = $("filter_tasks_by_name")
    el = $("filter_assigned");
    el_filter = $("filter_due_date");
    return if !el? && !el_filter?

    name_match = el_name.value
    assigned = (if el.value == 'all' then 'task' else el.value)
    filter = (if el_filter.value == 'all' then null else el_filter.value)

    @showAllTaskLists()
    @hideAllTasks()

    if name_match == "" && assigned == 'task' && filter == null
      @showAllTasks()
    else
      @showTasks(assigned, filter)
      @hideBySearchBox(name_match)
      @foldEmptyTaskLists()

    @updateCounts(true)
  
  hideBySearchBox: (matchText) ->
    matchText = matchText.toLowerCase()
    $$(".tasks div.task").each (t) ->
      if !t.down('a.name').innerHTML.toLowerCase().match(matchText)
        t.hide()

  updateCounts: (due_only) ->
    if !@assigned_options? && !@count_due_date?
      Filter.init()

    el = $("filter_assigned")
    el_filter = $("filter_due_date")
    return if !el?
    
    current_assigned = el.value
    assigned = (if el.value == 'all' then 'task' else el.value)
    count_due_date = @count_due_date
    assigned_options = @assigned_options
    
    unless due_only
      el.options.length = 0
      idx = 0
      for option in assigned_options
        if option.disabled
          el.options[idx] = new Option(option.text, option.value)
          el.options[idx].disabled = true
          idx += 1
        else
          filter = (if option.value == 'all' then 'task' else option.value)
          count = @countTasks(filter, null)
          if _i < 3 || count > 0 || filter == current_assigned
            el.options[idx] = (new Option(option.text + ' (' + count + ')', filter))
            idx += 1
      el.value = current_assigned

    for option in el_filter.options
      continue if (option.disabled)
      filter = (if option.value == 'all' then null else option.value)
      option.text = "#{count_due_date[_i]}  (#{@countTasks(assigned, filter)})"


document.on 'keyup', '#filter_tasks_by_name',
  ((evt,el) ->
    Filter.updateFilters()
  ).throttle(200) # throttling the function improves performance

# handles the "clear searchbox" event for webkit
document.on 'click', '#filter_tasks_by_name', (evt,el) ->
  Filter.updateFilters()

document.on "change", "#filter_tasks_by_name, #filter_assigned, #filter_due_date", (evt, el) ->
  Filter.updateFilters()
  print_link = $$('.print_link').first()
  print_link.href = window.location.href + '.print?filter_assigned=' + $('filter_assigned').value + '&filter_due_date=' + $('filter_due_date').value + '&filter_tasks_by_name='  + $('filter_tasks_by_name').value
