(function  () {

  var Uploader = function(view, opts) {

    this.options = {
      runtimes : 'html5,html4'
      , required_features: 'multipart'
      , max_file_size : '10mb'
      , file_data_name: 'comments_attributes[0]uploads_attributes[0][asset]'
      , multipart: true
    };
    this.view = view;
    this.opts = opts;
    this.inited = false;
    this.onFilesAdded = opts.onFilesAdded;
    this.onFilesRemoved = opts.onFilesRemoved;
    this.onFileUploaded = opts.onFileUploaded;
    this.onInit = opts.onInit;
    delete opts.onFilesAdded;
    delete opts.onFilesRemoved;
    delete opts.onFileUploaded;
    delete opts.onInit;
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

      var opts = {
          multipart_params: _.extend(data, { _method: 'put'})
        , headers: {
              'Accept':           'application/json'
            , 'X-PushSession-ID': Teambox.controllers.application.push_session_id
          }
      };

      _.extend(uploader.settings, opts);
    }.bind(this));


    this.uploader.bind('FilesAdded', this.onFilesAdded);
    this.uploader.bind('FilesRemoved', this.onFilesRemoved);

    this.uploader.bind('UploadProgress', function(up, file) {
      console.log("Uploading: " + file.percent + "%");
    });

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

  // export
  Teambox.modules.Uploader = Uploader;

}());

