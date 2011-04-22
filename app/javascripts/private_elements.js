PrivateBox = {

  peopleHTML: function(project_id) {
    var people = _people[project_id];
    var html = "";
    html = "<div class='private_users'>";
    html += people.collect(function(p) {
      if (p[3] == my_user.id) { return null; }
      return '<label><input checked="checked" name="private_ids[]" type="checkbox" value="'+p[3]+'">'+p[2]+'</label>';
    }).compact().join("");
    html += "</div>";
    return html;
  }

};

document.on("click", "a.private_switch", function(e,el) {
  e.stop();
  el.up('.thread').down('.private_options').toggle();
});

document.on("click", ".private_options .option.normal", function(e,el) {
  var box = el.up('.thread').down('.private_options');
  box.select('.private_users').invoke('remove');
});

document.on("click", ".private_options .option.private", function(e,el) {
  var box = el.up('.thread').down('.private_options');
  var project_id = el.up('.thread').readAttribute('data-project-id');
  box.select('.private_users').invoke('remove');
  box.insert({ bottom: PrivateBox.peopleHTML(project_id) });
});
