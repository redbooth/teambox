(function () {

  var UploadArea = { className: 'upload_area'
                   , template: Handlebars.compile(Templates.partials.upload_area)
                   };

  UploadArea.events = {
    'click .upload_file_button': 'showNewUpload'
  , 'change .upload_area input[type=file]': 'insertNewUpload'
  , 'click .uploads .upload .header': 'toggleReference'
  };

  UploadArea.initialize = function (options) {
    _.bindAll(this, "render");
    options = options || {};

    this.comment_form = options.comment_form;
  };


  // Draw the Add UploadArea box and populate it with watchers
  UploadArea.render = function () {
    this.el
      .setStyle({display: 'none'})
      .update(this.template(this.comment_form.model.getAttributes()));
    return this;
  };

  UploadArea.onFileUploaded = function(uploader, file, response) {
    var resp = JSON.parse(response.response)
    , status = response.status;

    if (status === 200) {
      this.comment_form.model.set(resp.objects);
      this.comment_form.addComment(false, resp);
    }
    else {
      this.comment_form.handleError(false, resp);
    }
  };

  UploadArea.onFilesAdded = function(uploader, files) {
    if (files.length === 1) {
      this.comment_form.el.select('input[type=submit]').each(function(input) {
        input.on('click', function(e) {
          uploader.start();
          e.stop();
        }.bind(this));
      }.bind(this));
    }

    var file_list = '';
    _.each(files, function(file, i) {
      file_list += '<li id="' + file.id + '">' + file.name + ' (' + plupload.formatSize(file.size) + ')' + '</li>';
    });

    this.el.select('.file_list')[0].update(file_list);

    uploader.refresh(); // Reposition Flash/Silverlight
  };

  /* show new upload
   *
   * @param {Event} evt
   */
  UploadArea.showNewUpload = function (evt) {
    // var el = evt.element;
    // if (!evt.isMiddleClick()) {
    //   evt.preventDefault();
    // }
  };


  /* inserts new upload
   *
   * @param {Event} evt
   */
  UploadArea.insertNewUpload = function (evt) {

    function incrementLastNumber(str) {
      var i = 0, matches = str.match(/\d+/g);

      matches.push(parseInt(matches.pop(), 10) + 1);
      return str.gsub(/\d+/, function (m) {
        return matches[i++];
      });
    }

    var el = evt.element()
      , new_input = new Element('input', {type: 'file', name: el.name /*incrementLastNumber(el.name)*/});

    if (!this.comment_form.hasEmptyFileUploads()) {
      el.insert({after: new_input});
    }
  };

  /* toggle reference
   *
   * @param {Event} evt
   */
  UploadArea.toggleReference = function (evt) {
    evt.stop();

    var el = evt.element()
      , reference = el.up('.upload').down('.reference');

    if (reference.visible()) {
      reference.hide();
    } else {
      $$('.uploads .upload .reference').invoke('hide');
      reference.show();
    }
  };

  // exports
  Teambox.Views.UploadArea = Backbone.View.extend(UploadArea);
}());
