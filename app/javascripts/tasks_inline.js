InlineTasks = {

  toggleFold: function(task) {
    var thread_block = task.down('.thread');
    if (task.hasClassName('expanded')) {
      task.removeClassName('expanded');
      new Effect.BlindUp(thread_block, {duration: 0.3});
      new Effect.Fade(task.down('.expanded_actions'), {duration: 0.3});
    } else {
      new Effect.BlindDown(thread_block, {duration: 0.3});
      new Effect.Appear(task.down('.expanded_actions'), {duration: 0.3});
      task.addClassName('expanded');
      Date.format_posted_dates();
      Task.insertAssignableUsers();
    }
  }
};

// Expand/collapse task threads inline in TaskLists#index
document.on('click', '.task a.name, .task a.hide', function(e, el) {
  if (e.isMiddleClick()) { return; }
  e.stop();

  InlineTasks.toggleFold(el.up('.task'));
});
