Event.addBehavior({
  "#user_all:click": function(e){
    var target = e.element();
    var enabled = target.checked;
    $$('.watchers .user input').each(function(el){
      el.checked = enabled;
    });
  },

  ".watchers .user input:click": function(e){
    var target = e.element();
    if (!target.checked)
      $('user_all').checked = false;
  }
});
