document.observe("dom:loaded", function(){
  var task_div_ids = $$(".tasks").map(function(task_div){
    return task_div.identify();
  })
  task_div_ids.each(function(task_div_id){
    Sortable.create(task_div_id, {
      constraint:'vertical',
      containment: task_div_ids,
      format:/task_(\d+)/,
      handle:'img.drag',
      // that makes the task disappear when it leaves its original task list
      // only:'task',
      tag:'div',
      onUpdate: function(){
        new Ajax.Request($(task_div_id).readAttribute("reorder_url"), {
          asynchronous: true,
          evalScripts: true,
          parameters: Sortable.serialize(task_div_id)
        })
      }
    })
  })
});