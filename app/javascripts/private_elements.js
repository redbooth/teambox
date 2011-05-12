PrivateBox = {

  redrawBox: function(form, project_id) {
    var box = form.down('.private_options');
    box.select('.private_users').invoke('remove');

    // Check for watcher list in thread
    var thread = box.up('.thread')
    var watcher_ids = null;
    var is_private = false;
    if (thread) {
      watcher_ids = (thread.readAttribute('data-watcher-ids')||'').split(',');
      is_private = thread.hasClassName('private')
    }

    // Update buttons & people list
    var watchers = form.down('.watchers'); // see new conversation form
    var private_input = box.down('.option.private input');
    if (private_input && private_input.checked) {
      box.insert({ bottom: this.peopleHTML(box.readAttribute('object-prefix'),
                                           box.readAttribute('object-type'),
                                           project_id, watcher_ids) });
      if (watchers) {
        watchers.select('input').invoke('disable');
        watchers.hide();
      }
    } else if (private_input && watchers) {
      watchers.select('input').invoke('enable');
      watchers.show();
    } else if (!private_input && is_private) {
      box.insert({ bottom: this.peopleShowHTML(box.readAttribute('object-prefix'),
                                           box.readAttribute('object-type'),
                                           project_id, watcher_ids) });
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
  },

  peopleShowHTML: function(object_id, object_type, project_id, watcher_ids) {
    var people = _people[project_id];
    var html = "";
    html = "<div class='private_users'>";
    html += people.collect(function(p) {
      var is_checked = (watcher_ids == null || watcher_ids.indexOf(p[3]) >= 0) ? 'checked="checked"' : '';
      if (!is_checked)
        return '';
      else
        return '<div class="private_user"><label>'+p[2]+'</label></div>';
    }).compact().join("");
    html += "</div>";
    return html;
  },

  activate: function(form, thread, can_modify){
    var box = form.down('.private_options');
    var can_modify = thread ? thread.readAttribute('data-creator-user-id') == my_user.id : true;
    var private_set = thread ? thread.hasClassName('private') : false

    if (can_modify) {
      box.insert({bottom: Mustache.to_html(Templates.comments.private_box, {
        object_prefix: box.readAttribute('object-prefix'),
        object_type: box.readAttribute('object-type'),
        is_public: I18n.translations.comments['private']['public'],
        is_private: I18n.translations.comments['private']['private']
      })});

      if (private_set)
        box.down('.option.private input').checked = true;
      else
        box.down('.option.normal input').checked = true;
    } else {
      // readonly display of watchers
      box.insert({bottom: Mustache.to_html(Templates.comments.private_box_readonly, {
        is_public: I18n.translations.comments['private']['public'],
        is_private: I18n.translations.comments['private']['private_global']
      })});

      if (private_set)
        box.down('.option.normal').hide();
      else
        box.down('.option.private').hide();
    }
  }

};

document.on("click", "a.private_switch", function(e,el) {
  e.stop();

  // Make sure the private options are populated
  if (el.readAttribute('form-present') != '1') {
    var form = el.up('form')
    var extra = form.down('.extra')
    var thread = form.up('.thread')
    PrivateBox.activate(form, thread)
    el.writeAttribute('form-present', '1')
  }

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