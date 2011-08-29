Upload = {

  parseCurrentFoldersForMove: function() {
    return my_current_folders;
  },

  renderMoveForm: function(upload_id) {
    return Mustache.to_html(Templates.uploads.move, {
        upload_id: upload_id,
        path: '/projects/' + current_project + '/move/' + upload_id,
        folders: Upload.parseCurrentFoldersForMove()
    })
  },

  getIdFromElement: function(el) {
    el_id = el.hasAttribute('id') ? el.getAttribute('id') : el.up('.upload').getAttribute('id');
    arr = el_id.split('_');
    return arr[1];
  },

  submitMoveForm: function() {
    $('move_form').request({
      method: 'put'
    });
  }

}

document.on('click', '.upload .reference a.move_resource', function(e, el){

  e.preventDefault();
  upload_id = Upload.getIdFromElement(el);
  console.log(upload_id);
  move_html = Upload.renderMoveForm(upload_id);
        
  Prototype.Facebox.open(move_html, 'html move_to_folder_box', {
      buttons: [
          {className: 'close', href: '#close', description: I18n.translations.common.cancel},
          {className: 'confirm', href: 'javascript:Upload.submitMoveForm()', description: I18n.translations.common.move}]
	});
});

document.on('click', '#upload_file_button', function(e, button) {
  e.preventDefault();
  $('new_upload').toggle();
});

// Display spinner wheel when loading folders via AJAX
document.on("click", ".upload .file a.ajax", function(e,el) {
  el.up('.upload').down('img').setAttribute('src', '/images/loading.gif');
});

document.on("click", ".upload .reference a.link_rename", function(e,el) {
  el.up('.reference').hide();
  el.up('.reference').up('.upload').down('.header').down('.icon').down('img').setAttribute('src', '/images/loading.gif');
});

document.on('click', '#new_folder_button, #new_folder_form a.close', function(e, button) {
  e.preventDefault();
  $('new_folder_form').toggle();
  if ($('new_folder_form').visible()) {
    $('new_folder_form').down('#new_folder_name').focus();
  }
});

String.prototype.incrementLastNumber = function() {
  var i = 0, matches = this.match(/\d+/g);
  matches.push(parseInt(matches.pop()) + 1);
  return this.gsub(/\d+/, function(m) { return matches[i++]; });
};

document.on('change', '.upload_area input[type=file]', function(e, input) {
  var newInput = new Element('input', {
    type: 'file',
    name: input.name.incrementLastNumber()
  });
  if (input.form.hasEmptyFileUploads() === false) {
    input.insert({ after: newInput });
  }
});

var toggle_task_row = function(el) {
  var upload = el.up('.upload');
  var reference = upload.down('.reference');
  if(reference) {
    if (reference.visible()) {
      upload.removeClassName('selected');
      reference.hide();
    } else {
      $$('.uploads .upload').invoke('removeClassName', 'selected');
      $$('.uploads .reference').invoke('hide');
      upload.addClassName('selected');
      reference.show();
    }
  }
};

// If clicked on the name, perform the default action
document.on('click', '.uploads .upload .header .file a', function(e, el) {
  toggle_task_row(el);
});

// When clicking on the row, display the dropdown menu
document.on('click', '.uploads .upload .header', function(e, el) {
  toggle_task_row(el);
});

/*
var move_resource = function(project_id, resource_id, moveable_type) {

   var div =  new Element('div', { id: 'move_resource'});
   div.innerHTML = 'Move to another folder:';

   var form = new Element('form', {
                         action: '/projects/' + project_id + '/move/' + resource_id,
                         method: 'post',
                         'data-remote': 'true',
                         onsubmit: 'Facebox.close()'
                       });
   div.appendChild(form);

   hidden_method = new Element('input', { type: 'hidden', name: "_method", value: "put"});
   form.appendChild(hidden_method);

   hidden_moveable_type = new Element('input', { type: 'hidden', name: "moveable_type", value: moveable_type});
   form.appendChild(hidden_moveable_type);

   if(typeof AUTH_TOKEN !== 'undefined') {
     hidden_auth_token = new Element('input', { type: 'hidden', name: "authenticity_token", value: AUTH_TOKEN});
     form.appendChild(hidden_auth_token);
   }
  
   var select = new Element('select', { name: "target_folder_id", id: "target_folder_id"});
   for (var id in target_folders) {
     if(!(moveable_type == 'folder' && resource_id == id)) {
        select.options.add(new Option(target_folders[id], id));
     }
   }
   form.appendChild(select);

   var submit = new Element('input', { type: 'submit', value: "Move"});
   form.appendChild(submit);

   Facebox.open(div);
};*/
