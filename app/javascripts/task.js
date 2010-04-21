Task = {

  makeSortable: function(task_id, all_task_ids) {
    Sortable.create(task_id, {
      constraint:'vertical',
      containment: all_task_ids,
      format: /.*task_(\d+)_task_task/,
      handle:'img.task_drag',
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
    var task_div_ids = $$(".tasks.open").map(function(task_div){
      return task_div.identify();
    })
    task_div_ids.each(function(task_div_id){
      Task.makeSortable(task_div_id, task_div_ids);
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

  insertTask: function(task_list_id, archived, task_id, html) {
    var container = archived ? $(task_list_id + '_the_closed_tasks') : $(task_list_id + '_the_main_tasks');
    container.insert({bottom: html});
    new Effect.Highlight(task_id, { duration: 3 });
    TaskList.updateList(task_list_id);
  },

  removeTask: function(task_list_id, task_id) {
    $(task_id).remove();
    TaskList.updateList(task_list_id);
  },

  destroy: function(element, url) {
    new Ajax.Request(url, {
      method: 'delete',
      asynchronous: true,
      evalScripts: true,
      onLoading: function() {
        //element.up('.actions_menu').hide();
      },
      onSuccess: function(response){
        // ...
      },
      onFailure: function(response){	
        //element.up('.actions_menu').show();
      }
    });
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

document.on('mouseover', '.task_list .task', function(e, element) {
  var drag = element.down('img.task_drag');
  if (drag) {
    drag.setAttribute('style', 'display:block');
    //element.down('span.task_status').hide();
  }
});

document.on('mouseout', '.task_list .task', 	function(e, element) {
  $$(".task img.task_drag").each(function(e){ e.hide(); });
  //$$(".task span.task_status").each(function(e){ e.show(); });
});

document.on('click', 'a.taskDelete', function(e, el) {
  e.stop();
  if (confirm(el.readAttribute('aconfirm')))
    Task.destroy(el, el.readAttribute('action_url'));
});

document.on('click', 'a.new_task_link', function(e, el) {
  e.stop();
  Jenny.toggleElement(el);
});

document.on('click', 'a.edit_task_link', function(e, el) {
  e.stop();
  Jenny.toggleElement(el);
});

document.observe('jenny:loaded:new_task', function(evt) {
  setTimeout(function(){
    Task.make_all_sortable();
    TaskList.saveColumn();
    TaskList.updatePage('column', TaskList.restoreColumn);
  }, 0);
});

document.observe('jenny:loaded:edit_task', function(evt) {
  setTimeout(function(){
    Task.make_all_sortable();
    TaskList.updatePage('column', TaskList.restoreColumn);
  }, 0);
});

document.observe('jenny:cancel:edit_task', function(evt) {
  $('show_task').down(".task_header").show();
});

// Enable task sort on load
document.observe('dom:loaded', function(e) {
	if ($$('.tasks').length > 0)
	  Task.make_all_sortable();
});

Event.addBehavior.reassignAfterAjax = true;