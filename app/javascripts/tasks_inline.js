InlineTasks = {

  toggleFold: function(task) {
    var block_id = "inline_"+task.readAttribute("id")

    if (task.hasClassName('expanded')) {
      task.removeClassName('expanded')
      new Effect.BlindUp(block_id, {duration: 0.5});
      new Effect.Fade(task.down('.expanded_actions'), {duration: 0.5})
      setTimeout(function() { $(block_id).remove() }, 500 )
    } else {
      if (!task.down('.loading_icon')) {
        task.down('span.task_status').insert({ before: "<div class='loading_icon'> </div>" })
        task.down('span.task_status').hide()
      }
      new Ajax.Request(task.down('a.name').readAttribute('href')+".html?nolayout=1", {
        method: "get",
        onSuccess: function(r) {
          task.down('.loading_icon').remove()
          task.down('span.task_status').show()
          var block = "<div class='task_inline' style='display:none' id='"+block_id+"'>"+r.responseText+"</div>"
          task.insert({ bottom: block })
          new Effect.BlindDown(block_id, {duration: 0.5})
          new Effect.Appear(task.down('.expanded_actions'), {duration: 0.5})
          task.addClassName('expanded')
          Date.format_posted_dates()
          Task.insertAssignableUsers()
        },
        onFailure: function(r) {
          task.down('.loading_icon').remove()
          task.down('span.task_status').show()
        }
      })
    }
  }
  
}
// Expand/collapse task threads inline in TaskLists#index
document.on('click', '.task_list_container a.name, .task_list_container a.hide', function(e, el) {
  if (e.isMiddleClick()) return
  e.stop()

  InlineTasks.toggleFold(el.up('.task'))
})

