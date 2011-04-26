PrivateBox = {

  redrawBox: function(form, project_id) {
    var box = form.down('.private_options');
    box.select('.private_users').invoke('remove');
    box.insert({ bottom: this.peopleHTML(project_id) });
  },

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
  el.up('form').down('.private_options').toggle();
});

document.on("click", ".private_options .option.normal", function(e,el) {
  var box = el.up('form').down('.private_options');
  box.select('.private_users').invoke('remove');
});

document.on("click", ".private_options .option.private", function(e,el) {
  var form = el.up('form');
  var select = form.down('select#project_id');
  var project_id = form.readAttribute('data-project-id') || select.select('option').find(function(ele){return !!ele.selected;}).value;
  PrivateBox.redrawBox(form, project_id);
});

document.on("change", "select#project_id", function(e,el) {
  var select = el;
  var form = el.up("form");
  var project_id = select.select('option').find(function(ele){return !!ele.selected;}).value;
  PrivateBox.redrawBox(form, project_id);
});