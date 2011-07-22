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
    this.form = this.comment_form.form;
    this.model = this.comment_form.model;
  };

  /* updated upload area element
   */
  UploadArea.render = function () {
    this.el
      .setStyle({display: 'none'})
      .update(this.template(this.model.getAttributes()));

    return this;
  };

  /* checks if the form has file uploads
   *
   * @return {Boolean}
   */
  UploadArea.hasFileUploads = function () {
    return this.hasFileUploads();
  };

  /*  Delegates to Uploader module to start files upload
   */
  UploadArea.uploadFiles = function () {
    this.uploader.start();
  };

  /* checks if the form has empty file uploads
   *
   * @return {Boolean}
   */
  UploadArea.hasEmptyFileUploads = function () {
    return this.form.select('input[type=file]').any(function (input) {
      return !input.getValue();
    });
  };

  /* creates an iframe and uploads a file
   */
  UploadArea.uploadFile = function () {
    var self = this
      , iframe_id = 'file_upload_iframe' + Date.now()
      , iframe = new Element('iframe', {id: iframe_id, name: iframe_id}).hide()
      , authToken = $$('meta[name=csrf-token]').first().readAttribute('content')
      , authParam = $$('meta[name=csrf-param]').first().readAttribute('content');

    Teambox.helpers.forms.showDisabledInput(this.form);

    function changeFormat(action) {
      if (action.endsWith('.text')) {
        return action.gsub(/\.text$/, '');
      }
      else {
        return action.gsub(/(\/?)$/, function(m) { return '.text';});
      }
    };

    function callback() {
      // contentDocument doesn't work in IE (7)
      var iframe_body = (iframe.contentDocument || iframe.contentWindow.document).body
        , extra_input = self.form.down('input[name=iframe]')
        , response = JSON.parse(iframe_body.firstChild.innerHTML);

      if (iframe_body.className !== "error") {
        self.model.set(response.objects ? response.objects : response, {error: self.comment_form.handleError.bind(self)});
        self.comment_form.addComment(false, response, true);
      } else {
        self.comment_form.handleError(false, response);
      }

      iframe.remove();
      self.form.target = null;
      self.form.action = changeFormat(self.form.action);
      if (extra_input) {
        extra_input.remove();
      }
      self.reset();
      Teambox.helpers.forms.restoreDisabledInputs(self.form);
    }

    $(document.body).insert(iframe);
    this.form.target = iframe_id;
    this.form.action = changeFormat(this.form.action);
    this.form.insert(new Element('input', {type: 'hidden', name: 'iframe', value: true}));
    this.form.insert(new Element('input', {type: 'hidden', 'class': 'x-pushsession-id', name: '_x-pushsession-id', value: Teambox.controllers.application.push_session_id}));

    if (this.form[authParam]) {
     this.form[authParam].value = authToken;
    } else {
     this.form.insert(new Element('input', {type: 'hidden', name: authParam, value: authToken}).hide());
    }

    // for IE (7)
    iframe.onreadystatechange = function () {
     if (this.readyState === 'complete') {
       callback();
     }
    };

    // non-IE
    iframe.onload = callback;
    var data = _.deparam(this.form.serialize(), true);

    //Run data through validator first
    if (this.model._performValidation(_.extend(data, {type: this.model.className()}), {
          error: this.comment_form.handleError.bind(this.comment_form)})) {
     // we may have cancelled xhr, but we still need to trigger form submit manually
     this.form.submit();
    }
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

  /* Handle the UploadComplete event
   *
   * Resets the upload area
   *
   * @param {plupload.Uploader} uploader
   * @param {Object} file
   * @param {Object} response
   */
  UploadArea.onUploadComplete = function(uploader, files) {
    uploader.total.reset();
    this.reset();
    Teambox.helpers.forms.restoreDisabledInputs(this.form);
  };

  UploadArea.onUploadFile = function(uploader, file) {
    Teambox.helpers.forms.showDisabledInput(this.form);
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

    //TODO:
    //html5 returns a status attribute
    //flash does not
    if (!response.status) {
      status = 200;
    }

    if (status === 200) {
      this.model.set(resp.objects);
      this.comment_form.addComment(false, resp, true);
    }
    else {
      this.comment_form.handleError(false, resp);
    }
  };

  /*  Returns wether there are any files in the file list pending upload
   */
  UploadArea.hasFileUploads = function() {
    // For use with Teambox.modules.Uploader
    // return !(_.isEmpty(this.files));
    // For simple iframe uploads
    return this.el.select('input[type=file]').any(function (input) {
      return input.getValue();
    });
  };

  /*  Resets the form
   */
  UploadArea.reset = function () {
    this.files = [];

    this.el.select('.file_list li').invoke('remove');
    // clear populated file uploads
    this.el.select('input[type=file]').each(function (input) {
      if (input.getValue()) {
        input.remove();
      }
    });
    this.el.select('input[type=file]').each(function (input) {
      input.setAttribute('name', 'comments_attributes[0][uploads_attributes][0][asset]');
    });

    if (this.el.visible()) {
      this.comment_form.toggleAttach();
    }
  };

  /*
   * Renders file list upon a file being added
   */
  UploadArea.renderFileList = function() {
    var self = this
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
   * Updates progress bars with upload progress
   *
   * @param {plupload.Uploader} uploader
   * @param {Object} file
   */
  UploadArea.onUploadProgress = function(uploader, file) {
    var self = this
    ,   width = 100
    ,   fileList = this.el.select('.file_list')[0];

    var progress_bar = fileList.select('li#file_' + file.id + ' div.progressbar')[0];

    if (progress_bar) {
      progress_bar.show();

      fileList.select('li#file_' + file.id + ' div.progressbar div').each(function(bar) {
        var px = width*(file.percent/100)
        ,   style = '' + px + 'px';
        bar.setStyle('width', style);
      });
    }
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
    var el = evt.element;
    if (!evt.isMiddleClick()) {
      evt.preventDefault();
      $('new_upload').show();
      el.hide();
    }
  };

  /* inserts new upload
   *
   * @param {Event} evt
   */
  UploadArea.insertNewUpload = function (evt) {

    function incrementLastNumber(str) {
      var i = 0, matches = str.match(/\[(\d)\]([^\d]+)$/);

      return str.gsub(/\[(\d)\]([^\d]+)$/, function (m) {
        var rest = m.pop()
        , number = m.pop();

        m.push(parseInt(number, 10) + 1);
        m.push(rest);
        return "[" + m[1] + "]" + m[2];
      });
    }

    var el = evt.element()
      , new_input = new Element('input', {type: 'file', name: incrementLastNumber(el.name)});

    if (!this.hasEmptyFileUploads()) {
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
