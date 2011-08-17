(function() {

  var UploadAreaConv = {
      className: 'upload_area'
    , template: Teambox.modules.ViewCompiler('partials.upload_area_conversation')
  };

  UploadAreaConv.events = {
      'change input[type=file]' : 'addFile'
    , 'click .remove'           : 'removeFile'
  };

  UploadAreaConv.initialize = function(options) {
    _.bindAll(this, 'render', 'addFile');
    this.number = 0;
  };

  UploadAreaConv.render = function() {
    $(this.el).hide().update(this.template({number: this.number}));
    return this;
  };

  // Adds a file to the DOM
  UploadAreaConv.addFile = function(event) {
    var filename = event.srcElement.files[0].name;
    // M... Not gonna create a template for this :S
    $(this.el).down('.files ul').insert({ bottom: '<li>' + filename + '<span id="file_' + this.number + '" class="remove"></span></li>'});
    this.number ++;
    return this;
  };

  UploadAreaConv.removeFile = function(event) {
    // TODO: remove from real object
    $(event.target).up('li').remove();
  };

  UploadAreaConv.hasFileUploads = function() {
    return false;
  };

  // exports
  Teambox.Views.UploadAreaConv = Backbone.View.extend(UploadAreaConv);

}());
