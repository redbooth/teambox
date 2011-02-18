// This file handles the "Notify people" feature for comments
Watchers = {
  toggleBox: function(form, project_id) {
    this.redrawBox(form, project_id);
    form.down(".add_watchers_box").toggle(); 
  },
  redrawBox: function(form, project_id) {
    form.select(".watcher").invoke("remove");
    form.down(".add_watchers_box").insert({ bottom: this.watchersHTML(project_id) });
  },
  watchersHTML: function(project_id) {
    var people = _people[project_id];
    var html = "";
    html = "<div class='watcher'><a href='#' data-login='all'><strong>All users</strong></a></div>";
    html += people.collect(function(p) {
      if (p[3] == my_user.id) { return null; }
      return "<div class='watcher'><a href='#' data-login='"+p[1]+"'>"+p[2]+"</a></div>";
    }).compact().join("");
    return html;
  }
};

// Toggle the watchers pane
document.on("click", "a.add_watchers", function(e,el) {
  e.stop();
  var form = el.up('form');
  var select = form.down('select#project_id');
  var project_id = form.readAttribute('data-project-id') || select.select('option').find(function(ele){return !!ele.selected;}).value;
  Watchers.toggleBox(form, project_id);
});

// Update the watchers content when switching projects for Conversation#new
document.on("change", "select#project_id", function(e,el) {
  var select = el;
  var form = el.up("form");
  var project_id = select.select('option').find(function(ele){return !!ele.selected;}).value;
  Watchers.redrawBox(form, project_id);
});

// Add @username to the textarea when clicking on a user
document.on("click", ".watcher a", function(e,el) {
  e.stop();
  var textarea = el.up("form").down("textarea");
  var login = el.readAttribute('data-login');
  if (textarea.value.length > 0 && textarea.value[textarea.value.length-1] != " ") {
    textarea.value += " ";
  }
  textarea.value += "@"+login+" ";
  textarea.focus();
  textarea.setSelectionRange(textarea.value.length, textarea.value.length);
});

// Pop up a notice asking to notify users for new conversations
document.on("keyup", "form.new_conversation textarea", function(e,el) {
  if (el.value.length === 0) { return; }

  if (Watchers.notify_people_span) { return; }
  Watchers.notify_people_span = true;

  var note = el.up("form").down("span.new");
  note.show();
  var e1 = new Effect.Move(note, { x: 50, transition: Effect.Transitions.linear, duration: 0 });
  var e2 = new Effect.Move(note, { x: -50, transition: Effect.Transitions.spring, duration: 1.0 });
});
