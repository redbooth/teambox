// TODO: This should be moved to backbone
// These functions currently do nothing

// Update the watchers content when switching projects for Conversation#new
document.on("change", "select#project_id", function(e,el) {
  var select = el;
  var form = el.up("form");
  var project_id = select.select('option').find(function(ele){return !!ele.selected;}).value;
  Watchers.redrawBox(form, project_id);
});

// Pop up a notice asking to notify users for new conversations
document.on("keyup", "form.new_conversation textarea", function(e,el) {
  if (typeof window['Watchers'] == 'undefined') { return; }
  if (el.value.length === 0) { return; }

  if (Watchers.notify_people_span) { return; }
  Watchers.notify_people_span = true;

  var note = el.up("form").down("span.new");
  note.show();
  var e1 = new Effect.Move(note, { x: 50, transition: Effect.Transitions.linear, duration: 0 });
  var e2 = new Effect.Move(note, { x: -50, transition: Effect.Transitions.spring, duration: 1.0 });
});
