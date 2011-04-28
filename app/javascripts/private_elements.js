PrivateBox = {

  redrawBox: function(form, project_id) {
    var box = form.down('.private_options');
    box.select('.private_users').invoke('remove');

    var object_id = box.readAttribute('object-prefix');
    if (box.down('.option.private input').checked)
      box.insert({ bottom: this.peopleHTML(object_id, project_id) });
  },

  update: function(el) {
    var form = el.up('form');
    var select = $$('select#project_id');
    var project_id = form.readAttribute('data-project-id') || select[0].select('option').find(function(ele){return !!ele.selected;}).value;
    PrivateBox.redrawBox(form, project_id);
  },

  peopleHTML: function(object_id, project_id) {
    var people = _people[project_id];
    var html = "";
    html = "<div class='private_users'>";
    html += people.collect(function(p) {
      if (p[3] == my_user.id) return null;
      var ident = object_id +'_private_'+ p[3];
      return '<div class="private_user"><input checked="checked" name="private_ids[]" type="checkbox" value="'+p[3]+'" id="'+ ident + '"/><label for="' + ident + '">'+p[2]+'</label></div>';
    }).compact().join("");
    html += "</div>";
    return html;
  }

};

document.on("click", "a.private_switch", function(e,el) {
  e.stop();
  PrivateBox.update(el);
  el.up('form').down('.private_options').toggle();
});

document.on("change", ".private_options .option.normal input", function(e,el) {
  PrivateBox.update(el);
});

document.on("change", ".private_options .option.private input", function(e,el) {
  PrivateBox.update(el);
});

document.on("change", "select#project_id", function(e,el) {
  PrivateBox.update(el);
});