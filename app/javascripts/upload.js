document.on('click', '#upload_file_button', function(e, button) {
  e.preventDefault();
  $('new_upload').toggle();
});

// Display spinner wheel when loading folders via AJAX
document.on("click", ".upload .file a.ajax", function(e,el) {
  el.up('.upload').down('img').setAttribute('src', '/images/loading.gif');
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
