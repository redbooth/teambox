Task = {

  makeSortable: function(task_id, all_task_ids) {
    Sortable.create(task_id, {
      constraint:'vertical',
      containment: all_task_ids,
      format: /.*task_(\d+)_item/,
      handle:'img.drag',
      dropOnEmpty: true,
      // that makes the task disappear when it leaves its original task list
      // only:'task',
      tag:'div',
      onUpdate: function(){
        new Ajax.Request($(task_id).readAttribute("reorder_url"), {
          asynchronous: true,
          evalScripts: true,
          parameters: Sortable.serialize(task_id)
        })
      }
    })
  },

  make_all_sortable: function() {
    var task_div_ids = $$(".tasks").map(function(task_div){
      return task_div.identify();
    })
    task_div_ids.each(function(task_div_id){
      Task.makeSortable(task_div_id, task_div_ids);
    })
  },

  create: function(form, url) {
    new Ajax.Request(url, {
      asynchronous: true,
      evalScripts: true,
      parameters: form.serialize(),
      onLoading: function() {
        // show loading bubbles
        form.down('.loading').show();
      },
      onSuccess: function(response){
        form.down('.loading').hide();
        // make the form disappear
        form.hide();
        var new_task_link = form.up().down(".new_task_link");
        // make the Add task link appear
        new_task_link.show();
        // add a new task in the task list box to the bottom
        var list_of_tasks = form.up().down(".tasks");
        var task_item_html = response.responseText;
        var last_task_item = list_of_tasks.select('.task').select(Element.visible).last();
        if ( last_task_item !== undefined ) {
          last_task_item.insert({ after: task_item_html });
        } else {
          list_of_tasks.insert({ top: task_item_html });
        }

        Task.highlight_last_as_new(list_of_tasks);
        Task.make_all_sortable();

        var new_task = list_of_tasks.select('.task').last();
        var show_in_main_content_url = new_task.readAttribute('show_in_main_content_url');
        Task.show_in_main_content(show_in_main_content_url);
      },
      on403: function(response){
        form.down('.loading').hide();
        form.down('#task_name').focus();
        $$(".global_navigation").first().insert({
          after: '<div class="flash_box flash_error"><div>'+ response.responseText +'</div></div>'
        });
      }
    })
  },

  update: function(form, url) {
    new Ajax.Request(url, {
      asynchronous: true,
      evalScripts: true,
      parameters: form.serialize(),
      onLoading: function() {
        // show loading bubbles
        form.down('.loading').show();
      },
      onSuccess: function(response){
        form.down('.loading').hide();
        // make the form disappear
        form.hide();
        // make the Add task link appear
        form.up().down(".new_task_link").show();
      }
    })
  },

  highlight_last_as_new: function(list_of_tasks) {
    var new_task = list_of_tasks.select('.task').last();
    list_of_tasks.select('.task').each(function(task){
      task.removeClassName('active_new');
    })
    new_task.addClassName('active_new');
  },

  show_in_main_content: function(url) {
    new Ajax.Request(url, {
      asynchronous: true,
      evalScripts: true,
      method: 'get',
      onSuccess: function(response){
        $('content').update(response.responseText);
      }
    })
  }

}

Element.addMethods({
  toggleAttribute: function(element, attr, values) {
    element = $(element);
    var value = element.readAttribute(attr);
    var newIndex = (values.indexOf(value) + 1) % values.length;
    element.writeAttribute(attr, values[newIndex]);
  },
  toggleShowAttribute: function(element, values) {
    element.toggleAttribute("show", values);
  },
})


Event.addBehavior({
  ".task:mouseover": function(e){
    $(this).down('img.drag').show();
    $(this).down('span.task_status').hide();
  },
  ".task:mouseout": function(e){
    $$(".task img.drag").each(function(e){ e.hide(); });
    $$(".task span.task_status").each(function(e){ e.show(); });
  },
  ".inline_form_create:click": function(e) {
    var form = e.findElement("form");
    var submit_url = form.readAttribute("action");
    Task.create(form, submit_url);
    e.stop();
  },
  ".inline_form_update:click": function(e) {
    var form = e.findElement("form");
    var submit_url = form.readAttribute("action");
    Task.update(form, submit_url);
    e.stop();
  },
  ".inline_form_create_cancel:click": function(e){
    var form = e.findElement("form");
    form.up().down(".new_task_link").show();
    form.hide();
  },
  ".inline_form_update_cancel:click": function(e){
    var form = e.findElement("form");
    form.up().down(".task_header").show();
    form.hide();
  }
});

Event.addBehavior.reassignAfterAjax = true;