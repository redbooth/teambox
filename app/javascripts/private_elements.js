PrivateBox = {

  redrawBox: function(form, project_id) {
    var box = form.down('.private_options');
    box.select('.private_users').invoke('remove');

    // Check for watcher list in thread
    var thread = box.up('.thread')
    var watcher_ids = null;
    if (thread)
      watcher_ids = (thread.readAttribute('data-watcher-ids')||'').split(',');

    // Update buttons & people list
    var watchers = form.down('.watchers');
    if (box.down('.option.private input').checked) {
      box.insert({ bottom: this.peopleHTML(box.readAttribute('object-prefix'),
                                           box.readAttribute('object-type'),
                                           project_id, watcher_ids) });
      if (watchers) {
        watchers.select('input').invoke('disable');
        watchers.hide();
      }
    } else if (watchers) {
      watchers.select('input').invoke('enable');
      watchers.show();
    }
  },

  update: function(el) {
    var form = el.up('form');
    var select = $$('select#project_id');
    var project_id = form.readAttribute('data-project-id') || select[0].select('option').find(function(ele){return !!ele.selected;}).value;
    PrivateBox.redrawBox(form, project_id);
  },

  peopleHTML: function(object_id, object_type, project_id, watcher_ids) {
    var people = _people[project_id];
    var html = "";
    html = "<div class='private_users'>";
    html += people.collect(function(p) {
      if (p[3] == my_user.id) return '<input type="hidden" name="'+object_type+'[private_ids][]" type="checkbox" value="'+p[3]+'"/>';
      var ident = object_id +'_private_'+ p[3];
      var is_checked = (watcher_ids == null || watcher_ids.indexOf(p[3]) >= 0) ? 'checked="checked"' : '';
      return '<div class="private_user"><input '+is_checked+' name="'+object_type+'[private_ids][]" type="checkbox" value="'+p[3]+'" id="'+ ident + '"/><label for="' + ident + '">'+p[2]+'</label></div>';
    }).compact().join("");
    html += "</div>";
    return html;
  }

};

document.on("click", "a.private_switch", function(e,el) {
  e.stop();
  PrivateBox.update(el);

  var options = el.up('form').down('.private_options')
  if (options.visible()) {
    options.select('input').invoke('disable');
    options.hide();
  } else {
    options.select('input').invoke('enable');
    options.show();
  }
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