PrivateBox = {

  findUser: function(project_id, user_id) {
    var people = _people[project_id];
    var len = people.length;
    for (var i=0; i<len; i++) {
      var p = people[i];
      if (p[3] == user_id)
        return p;
    }
    return null;
  },

  allUsersEnabled: function(private_users) {
	var count = 0
    var users = private_users.select('.private_user input')
    users.each(function(fe){ if (fe.checked) count += 1 })
    return count == users.length
  },

  updateAllUsersEnabled: function(users) {
    users.down('.private_all input').checked = PrivateBox.allUsersEnabled(users)
  },

  redrawBox: function(form, project_id) {
    var box = form.down('.private_options');
    box.select('.private_users').invoke('remove');
    box.select('.readonly_warning').invoke('remove');

    // Check for watcher list in thread
    var thread = box.up('.thread')
    var watcher_ids = null;
    var is_private = false;
    var creator_id = null;
    var assigned_id = null;
    if (thread) {
      watcher_ids = (thread.readAttribute('data-watcher-ids')||'').split(',');
      is_private = thread.hasClassName('private');
      creator_id = thread.readAttribute('data-creator-user-id');
      assigned_id = thread.readAttribute('data-assigned-id');
    }

    // Update buttons & people list
    var watchers = form.down('.watchers'); // see new conversation form
    var private_input = box.down('.option.private input');
    var public_input = box.down('.option.normal input');
    if (private_input && private_input.checked) {
      box.insert({ bottom: this.peopleHTML(box.readAttribute('object-prefix'),
                                           box.readAttribute('object-type'),
                                           project_id, watcher_ids, assigned_id) });
      if (watchers) {
        watchers.select('input').invoke('disable');
        watchers.hide();
      }
      // Update All input
      PrivateBox.updateAllUsersEnabled(box.down('.private_users'));
    } else if (private_input && watchers) {
      watchers.select('input').invoke('enable');
      watchers.show();
    } else if (!private_input && is_private) {
      box.insert({ bottom: this.peopleShowHTML(box.readAttribute('object-prefix'),
                                           box.readAttribute('object-type'),
                                           project_id, watcher_ids) });
      var creator = PrivateBox.findUser(project_id, creator_id);
      if (creator)
        box.insert({ bottom: '<p class="readonly_warning">' +
                             I18n.t(I18n.translations.comments['private']['readonly_warning'], {user: '<a href="/users/'+creator_id+'">'+creator[2]+'</a>'}) +
                             '</p>'})
    }
  },

  update: function(el) {
    var form = el.up('form');
    var select = $$('select#project_id');
    var project_id = form.readAttribute('data-project-id') || select[0].select('option').find(function(ele){return !!ele.selected;}).value;
    
    // Forever alone
    var private_option = form.down('.option.private input');
    if (private_option) {
      var text = _people[project_id].length == 1 ? I18n.translations.comments['private']['private_foreveralone'] : I18n.translations.comments['private']['private'];
	  form.down('.option.private label').update(text);
    }

    PrivateBox.redrawBox(form, project_id);
  },

  peopleHTML: function(object_id, object_type, project_id, watcher_ids, assigned_id) {
    var people = _people[project_id];
    var html = "";
    html = "<div class='private_users'>";
    html += '<div class="private_all"><input id="'+object_id +'_private_all" name="'+object_type+'[all_private]" type="checkbox" value="true"/><label for="'+object_id +'_private_all">'+ I18n.translations.comments['private']['all'] +'</label></div>';
    html += people.collect(function(p) {
      if (p[3] == my_user.id || p[0] == assigned_id) return '<input type="hidden" name="'+object_type+'[private_ids][]" type="checkbox" value="'+p[3]+'"/>';
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

  var options = el.up('form').down('.private_options')
  if (options.visible()) {
    options.select('input').invoke('disable');
  } else {
    options.select('input').invoke('enable');
  }

  PrivateBox.update(el);

  if (options.visible()) {
    options.hide();
  } else {
    options.show();
  }
});

document.on("change", ".private_options .option.normal input", function(e,el) {
  PrivateBox.update(el);
});

document.on("change", ".private_users .private_all input", function(e,el) {
  el.up('.private_users').select('.private_user input').each(function(fe){ fe.checked = el.checked; })
});

document.on("change", ".private_users .private_user input", function(e,el) {
  var users = el.up('.private_users')
  users.down('.private_all input').checked = PrivateBox.allUsersEnabled(users)
});

document.on("change", ".private_options .option.private input", function(e,el) {
  PrivateBox.update(el);
});

document.on("change", "select#project_id", function(e,el) {
  PrivateBox.update(el);
});

document.on("dom:loaded", function (e,el) {
  if (el.body.hasClassName('edit_pages') || el.body.hasClassName('new_pages')) {
	var form = $(el.body).down('.content').down('form')
    PrivateBox.activate(form, form)
    PrivateBox.update(form.down('div'))
    form.down('.private_options').select('input').invoke('enable');
  }
})
