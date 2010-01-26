Task = {

  make_sortable: function(task_id, all_task_ids) {
    Sortable.create(task_id, {
      constraint:'vertical',
      containment: all_task_ids,
      format: /.*task_(\d+)_item/,
      handle:'img.drag',
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
      Task.make_sortable(task_div_id, task_div_ids);
    })
  },

  make_cancel_links: function() {
    $$(".inline_form_cancel").each(function(cancel_link){
      cancel_link.observe('click', function(event){
        var form = event.findElement("form");
        // make the Add task link appear
        form.up().down(".new_task_link").show();
        // hide the form
        form.hide();
      })
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
        // make the Add task link appear
        form.up().down(".new_task_link").show();
        // add a new task in the task list box to the bottom
        var list_of_tasks = form.up().down(".tasks");
        var task_item_html = response.responseText;
        list_of_tasks.insert({ bottom: task_item_html })

        Task.highlight_last_as_new(list_of_tasks);
        Task.make_all_sortable();

        var new_task = list_of_tasks.select('.task').last();
        var show_in_main_content_url = new_task.readAttribute('show_in_main_content_url');
        Task.show_in_main_content(show_in_main_content_url);
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
        Element.replace('content', response.responseText);
      }
    })
  },

  bind_creation: function() {
    $$(".inline_form_submit").each(function(submit_button){
      submit_button.observe('click', function(event){
        var form = event.findElement("form");
        var submit_url = form.readAttribute("action");
        Task.create(form, submit_url);
        event.stop();
      })
    })
  }
}

document.observe("dom:loaded", function(){
  Task.make_all_sortable();
  Task.make_cancel_links();
  Task.bind_creation();
});