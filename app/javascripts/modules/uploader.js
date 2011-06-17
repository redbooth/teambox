(function  () {

  var Uploader = function(view, opts) {

    var host = document.location.protocol + '//' + document.location.host + '/'
    ,   flash_swf_url = host + 'plupload.flash.swf';

    this.options = {
      runtimes : 'flash,html4'
      , required_features: 'multipart'
      , max_file_size : '10mb'
      , file_data_name: 'comments_attributes[0]uploads_attributes[0][asset]'
      , flash_swf_url: flash_swf_url
      , multipart: true
      , urlstream_upload: true
    };
    this.view = view;
    this.opts = opts;
    this.inited = false;
    this.onFilesAdded = opts.onFilesAdded;
    this.onFilesRemoved = opts.onFilesRemoved;
    this.onFileUploaded = opts.onFileUploaded;
    this.onUploadProgress = opts.onUploadProgress;
    this.onUploadComplete = opts.onUploadComplete;
    this.onBeforeUpload = opts.onBeforeUpload;
    this.onUploadFile = opts.onUploadFile;
    this.onInit = opts.onInit;
    delete opts.onFilesAdded;
    delete opts.onFilesRemoved;
    delete opts.onFileUploaded;
    delete opts.onInit;
    delete opts.onUploadProgress;
    delete opts.onUploadComplete;
    delete opts.onBeforeUpload;
    delete opts.onUploadFile;
  };

  Uploader.prototype.init = function () {
    var view = this.view
    , model = this.view.model
    , form    = this.view.el
    , opts    = this.opts;

    var id = model.className().toLowerCase() + '_' + model.id
    , drop_element_id = "file_drop_" + id;

    var options = {
        container: "file_list_" + id
      , browse_button: "upload_file_" + id
      , drop_element: drop_element_id
      , url: model.url()
    };

    this.options = _.extend(this.options, options, opts);
    this.uploader = new plupload.Uploader(this.options);

    this.uploader.bind('Init', this.onInit);

    this.uploader.bind('UploadFile', function(uploader, file) {
      var data = this.view.el.serialize(true);

      //The things you have to do...
      for (key in data) {
        var value = data[key];
        delete data[key];
        data[key.replace(this.view.model.className().toLowerCase(), '')] = value;
      };

      if (!data.name) {
        data.name = this.view.model.get('name');
      }

      //These params are required for maintaining authenticity and session when going through flash engine
      var csrf_param = $$('meta[name=csrf-param]').first()
      ,   csrf_token = $$('meta[name=csrf-token]').first()
      ,   session_key = $$('meta[name=session-key]').first()
      ,   session_id  = $$('meta[name=session-id]').first();

      var fixed_opts = {
          _method: 'put'
        , '_x-pushsession-id': Teambox.controllers.application.push_session_id
      };

      if (csrf_param && csrf_token) {
        fixed_opts[csrf_param.getAttribute('content')] = csrf_token.getAttribute('content');
      }

      if (session_key && session_id) {
        fixed_opts[session_key.getAttribute('content')] = session_id.getAttribute('content');
      }

      var opts = {
          multipart_params: _.extend(data, fixed_opts)
        , headers: {
              'Accept':           'application/json'
            , 'X-PushSession-ID': Teambox.controllers.application.push_session_id
          }
      };

      _.extend(uploader.settings, opts);
      if (this.onUploadFile) {
        this.onUploadFile();
      }
    }.bind(this));


    this.uploader.bind('FilesAdded', this.onFilesAdded);
    this.uploader.bind('FilesRemoved', this.onFilesRemoved);
    this.uploader.bind('UploadProgress', this.onUploadProgress);
    this.uploader.bind('UploadComplete', this.onUploadComplete);

    this.uploader.bind('Error', function(uploader, err) {
      console.log('Error: ' + err.code + ", Message: " + err.message + (err.file ? ", File: " + err.file.name : ""));
      uploader.refresh(); // Reposition Flash/Silverlight
    });

    this.uploader.bind('FileUploaded', this.onFileUploaded);

	  this.uploader.init();
    this.inited = true;
  };

  /* Delegates to plupload.Uploader#start to start upload
  * */
  Uploader.prototype.start = function () {
    this.uploader.start();
  };

  /* Removes a file from the plupload.Uploader instance
  * */
  Uploader.prototype.removeFile = function (id) {
    var file = this.uploader.getFile(id);
    this.uploader.removeFile(file);
  };

  Uploader.prototype.hasPendingUploads = function() {
    return this.uploader.total.percent === 100;
  };

  Uploader.prototype.refresh = function() {
    return this.uploader.refresh();
  };


  // export
  Teambox.modules.Uploader = Uploader;

}());

