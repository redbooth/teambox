(function () {

  var UploadArea = { className: 'upload_area'
                   , template: Teambox.modules.ViewCompiler('partials.upload_area')
                   , fileListEntrytemplate: Teambox.modules.ViewCompiler('partials.upload_entry')
                   , files: []
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

  /* updated upload area element
   */
  UploadArea.render = function () {
    this.el
      .setStyle({display: 'none'})
      .update(this.template(this.comment_form.model.getAttributes()));

    return this;
  };

  /*  Enable/Disable functionality based on supported features
   *
   * @param {plupload.Uploader} uploader
   * @param {Object} params
   */
  UploadArea.onUploaderInit = function(uploader, params) {
    if (!!uploader.features.dragdrop) {
      var drop_element = $(uploader.settings.drop_element);
      this.drop_element = drop_element;
      this.drop_element.addClassName('filedrop');

      this.drop_element.on('dragenter', function(evt) {
        drop_element.addClassName('filedroppable');
      });

      this.drop_element.on('dragover', function(evt) {
        drop_element.addClassName('filedroppable');
      });

      this.drop_element.on('dragleave', function(evt) {
        drop_element.removeClassName('filedroppable');
      });

      this.drop_element.on('drop', function(evt) {
        drop_element.removeClassName('filedroppable');
      });

    }
  };

  /*  Handle the FileUploaded event
   *
   *  Updates the target model and adds a comment into the UI
   *
   * @param {plupload.Uploader} uploader
   * @param {Object} file
   * @param {Object} response
   */
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

  /*  Returns wether there are any files in the file list pending upload
   */
  UploadArea.hasFileUploads = function() {
    return !(_.isEmpty(this.files));
  };

  /*  Resets the form
   */
  UploadArea.reset = function () {
    this.files = [];

    if (this.el.visible()) {
      this.comment_form.toggleAttach();
    }
  };

  /*
   * Renders file list upon a file being added
   */
  UploadArea.renderFileList = function() {
    var self = this
    ,   li
    ,   a
    ,   text
    ,   fileList = this.el.select('.file_list')[0]
    ,   uploader = this.comment_form.uploader;

    var entries = this.fileListEntrytemplate({files: this.files});

    fileList.update(entries);
    fileList.select('li a').each(function(link) {
      link.on('click', function(evt) {
        evt.preventDefault();
        uploader.removeFile(evt.target.id);
      });
    });
  };

  /*
   * Concatenates new files to file queue
   *
   * @param {plupload.Uploader} uploader
   * @param {Array} files
   */
  UploadArea.onFilesAdded = function(uploader, files) {
    this.files = this.files.concat(files);
    this.renderFileList();
    uploader.refresh(); // Reposition Flash/Silverlight
  };

  /*
   * Removes files from file queue
   *
   * @param {plupload.Uploader} uploader
   * @param {Array} files
   */
  UploadArea.onFilesRemoved = function(uploader, files) {
    this.files = _.reject(this.files, function(file) {
      return _.any(files, function(f) { return f.id === file.id});
    });

    this.renderFileList();

    if (uploader) {
      uploader.refresh(); // Reposition Flash/Silverlight
    }
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
