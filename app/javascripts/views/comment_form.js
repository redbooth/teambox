(function () {

  var CommentForm = { tagName: 'form'
                    , className: 'new_comment'
                    , template: Teambox.modules.ViewCompiler('partials.comment_form')
                    };

  CommentForm.events = {
    'click a.attach_icon'          : 'toggleAttach'
  , 'click a.add_hours_icon'       : 'toggleHours'
  , 'click a.add_watchers'         : 'toggleWatchers'
  , 'focusin textarea'             : 'focusTextarea'
  , 'submit .new_comment'          : 'postComment'
  , 'click span.convert_to_task a' : 'toggleConvertToTask'
  , 'click .date_picker'           : 'showCalendar'
  };

  CommentForm.initialize = function (options) {
    _.bindAll(this, "render");

    this.convert_to_task = options.convert_to_task;
    this.upload_area = new Teambox.Views.UploadArea({comment_form: this});
    this.watchers = new Teambox.Views.Watchers({model: this.model});
  };

  /* Updates the comment_form el
   *
   * @returns self;
   */
  CommentForm.render = function () {

    this.el.writeAttribute({
      'accept-charset': 'UTF-8'
    , 'action': this.model.url()
    , 'data-project-id': this.model.get('project_id')
    , 'enctype': 'multipart/form-data'
    , 'method': 'POST'
    });

    this.el.addClassName("edit_" + this.model.get('type').toLowerCase());

    this.el.update(this.template(this.model.getAttributes()));

    // select status
    (new Teambox.Views.SelectStatus({
      el: this.el.select('#task_status')[0]
    , selected: this.model.get('status')
    })).render();

    // select assigned
    (new Teambox.Views.SelectAssigned({
      el: this.el.select('#task_assigned_id')[0]
    , selected: this.model.get('assigned_id')
    , project: Teambox.collections.projects.get(this.model.get('project_id'))
    })).render();

    if (/\d+$/.test(this.model.url())) {
      this.el.insert({top: new Element('input', {type: 'hidden', name: '_method', value: 'put'})});
    }


    this.el.down('.actions')
      // upload area
      .insert({before: this.upload_area.render().el})
      // watchers box
      .insert({before: this.watchers.render().el});

    return this;
  };

  /* Cleans the form
   *
   * @param {Event} evt
   * @returns false;
   */
  CommentForm.reset = function () {
    // clear comment and reset textarea height
    this.el.down('textarea').update('').setStyle({height: ''}).value = '';

    if (this.model.className() === 'Task') {
      this.el.down('.human_hours').value = '';
      this.el.select('.hours_field').invoke('hide');
    }

    this.el.select('.error').invoke('remove');
    this.el.select('.google_docs_attachment .fields input').invoke('remove');
    this.el.select('.google_docs_attachment .file_list li').invoke('remove');
    this.el.select('.x-pushsession-id').invoke('remove');
  };

  CommentForm.addComment = function (m, resp, upload) {
    var comment_attributes = this.model.parseComments(resp);

    this.reset();
    this.model.attributes.last_comment = comment_attributes;
    this.model.attributes.recent_comments.push(comment_attributes);
    this.model.trigger('comment:added', comment_attributes, _.clone(Teambox.models.user));
  };

  CommentForm.handleError = function (m, resp) {
    resp.errors.each(function (error) {
      self.el.down('div.text_area').insertOrUpdate('p.error', error.value);
    });
  };

  /* Syncs the new comment and triggers `comment:added`
   *
   * @param {Event} evt
   * @returns false;
   */
  CommentForm.postComment = function (evt) {
    var self = this
      , data;

    if (evt) {
      evt.stop();
    }

    if (this.upload_area.hasFileUploads()) {
      //Uses Teambox.modules.Uploader
      // return this.upload_area.uploadFiles();
      //Uses simple iframe uploading
      return this.upload_area.uploadFile();
    }

    data = _.deparam(this.el.serialize(), true);

    Teambox.helpers.forms.showDisabledInput(this.el);

    this.model.save(data, {
      success: this.addComment.bind(this)
    , failure: this.handleError.bind(this)
    });

    return false;
  };

  /* Toggle the attach files area
   *
   * @param {Event} evt
   */
  CommentForm.toggleAttach = function (evt) {
    if (evt) {
      evt.stop();
    }

    //TODO: Find a better place to init the uploader
    //Currently, plupload checks for file list container in DOM sw we
    //need to be sure it exists in DOM when intiting the uploader
    //Disabling plupload
    // this.initUploader();

    var upload_area = $(this.el).down('.upload_area');
    upload_area.toggle().highlight();

    // if (upload_area.visible()) {
    //   this.uploader.refresh();
    // }
  };

  /* inits the uploader
   */
  CommentForm.initUploader = function() {
    if (!this.uploader) {
      this.uploader = new Teambox.modules.Uploader(this, {
          onFilesAdded: this.upload_area.onFilesAdded.bind(this.upload_area)
        , onFilesRemoved: this.upload_area.onFilesRemoved.bind(this.upload_area)
        , onFileUploaded: this.upload_area.onFileUploaded.bind(this.upload_area)
        , onUploadProgress: this.upload_area.onUploadProgress.bind(this.upload_area)
        , onUploadComplete: this.upload_area.onUploadComplete.bind(this.upload_area)
        , onUploadFile: this.upload_area.onUploadFile.bind(this.upload_area)
        , onInit: this.upload_area.onUploaderInit.bind(this.upload_area)
      });
    }

    if (!this.uploader.inited) {
      this.uploader.init();
    }
  };

  /* Toggle the time tracking area
   *
   * @param {Event} evt
   */
  CommentForm.toggleHours = function (evt) {
    evt.stop();
    $(this.el).down('.hours_field').toggle().down('input').focus();
  };

  /* Toggle the convert to task area
   *
   * @param {Event} evt
   */
  CommentForm.toggleConvertToTask = function (evt) {
    this.convert_to_task.toggle(evt);
  };

  /* Toggle the "Add Watchers" area
   *
   * @param {Event} evt
   */
  CommentForm.toggleWatchers = function (evt) {
    evt.stop();
    this.el.down('.add_watchers_box').toggle();
  };

  /* Displays the calendar
   *
   * @param {Event} evt
   */
  CommentForm.showCalendar = function (evt, element) {
    evt.stop();

    new Teambox.modules.CalendarDateSelect(element.down('input'), element.down('span'), {
      buttons: true
    , popup: 'force'
    , time: false
    , year_range: [2008, 2020]
    });
  };

  /* Reveal the extra controls when focusing on the textarea
   * Assigns the autocompleter
   *
   * @param {Event} evt
   */
  CommentForm.focusTextarea = function (evt) {
    var textarea = evt.element()
      , people = Teambox.collections.projects.get(this.model.get('project_id')).getAutocompleterUserNames()
      , container;

    this.el.down('.extra').show();

    if (this.autocompleter) {
      this.autocompleter.options.array = people;
    } else {
      container = new Element('div', {'class': 'autocomplete'}).hide();
      textarea.insert({after: container});
      this.autocompleter = new Autocompleter.Local(textarea, container, people, {tokens: [' ']});
    }
  };

  /* Displays the calendar
   *
   * @param {Event} evt
   */
  CommentForm.showCalendar = function (evt, element) {
    evt.stop();

    new Teambox.modules.CalendarDateSelect(element.down('input'), element.down('span'), {
      buttons: true
    , popup: 'force'
    , time: false
    , year_range: [2008, 2020]
    });
  };




  // exports
  Teambox.Views.CommentForm = Backbone.View.extend(CommentForm);
}());
