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
  };

  Uploader.prototype.init = function () {
    var view = this.view
    , model = this.view.model
    , form    = this.view.el
    , opts    = this.opts;

    var id = model.className().toLowerCase() + '_' + model.id;

    var options = {
        container: "file_list_" + id
      , browse_button: "upload_file_" + id
      , drop_element: "upload_drop_" + id
      , url: model.url()
    };

    this.options = _.extend(this.options, options, opts);
    this.uploader = new plupload.Uploader(this.options);

    this.uploader.bind('Init', function(uploader, params) {
      if (!!uploader.features.dragdrop) {
        console.log('supports drag n drop....');
      }
    });

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


    this.uploader.bind('FilesAdded', function(uploader, files) {
      if (files.length === 1) {
        this.view.el.select('input[type=submit]').each(function(input) {
          input.on('click', function(e) {
            this.uploader.start();
            e.stop();
          }.bind(this));
        }.bind(this));
      }

      var file_list = '';
      _.each(files, function(file, i) {
        file_list += '<li id="' + file.id + '">' + file.name + ' (' + plupload.formatSize(file.size) + ')' + '</li>';
      });

      this.view.el.select('.file_list')[0].update(file_list);

      uploader.refresh(); // Reposition Flash/Silverlight
    }.bind(this));

    this.uploader.bind('UploadProgress', function(up, file) {
      console.log("Uploading: " + file.percent + "%");
    });

    this.uploader.bind('Error', function(uploader, err) {
      console.log('Error: ' + err.code + ", Message: " + err.message + (err.file ? ", File: " + err.file.name : ""));
      uploader.refresh(); // Reposition Flash/Silverlight
    });

    this.uploader.bind('FileUploaded', this.view.onFileUploaded.bind(this.view));

	  this.uploader.init();
    this.inited = true;
  };

  // export
  Teambox.modules.Uploader = Uploader;

}());


