(function () {

  var CommentForm = { className: 'new_comment_wrap'
                    , template: Teambox.modules.ViewCompiler('partials.comment_form')
                    , simple_template: Teambox.modules.ViewCompiler('partials.comment_form_simple')
                    };

  CommentForm.events = {
    'click a.attach_icon'          : 'toggleAttach'
  , 'click a.add_hours_icon'       : 'toggleHours'
  , 'click a.add_watchers'         : 'toggleWatchers'
  , 'submit .new_comment'          : 'postComment'
  , 'click a.convert_to_task'      : 'toggleConvertToTask'
  , 'click .date_picker'           : 'showCalendar'
  , 'click a.private_switch'       : 'togglePrivateElements'
  , 'click a.google_doc_icon'      : 'showGoogleDocs'
  , 'focusin textarea'             : 'focusTextarea'
  };

  CommentForm.initialize = function (options) {
    _.bindAll(this, "render");

    this.convert_to_task = options.convert_to_task;
    this.thread = options.thread;
    this.simple = options.simple;

    this.upload_area = new Teambox.Views.UploadArea({comment_form: this});
    this.watchers = new Teambox.Views.Watchers({model: this.model});
    this.private_elements = new Teambox.Views.PrivateElements({comment_form: this, model: this.model});
    this.google_docs = new Teambox.Views.GoogleDocs({comment_form: this});
  };

  /* Updates the comment_form el
   *
   * @returns self;
   */
  CommentForm.render = function () {
    var self = this;
    var template = this.simple ? this.simple_template : this.template;
    this.el.insert({bottom: template(_.extend({view: this}, this.model.getAttributes()))});

    this.form = this.el.down('form');
    this.delegateEventsTo(this.events, this.form);

    this.updateFormAttributes(this.model.get('project_id'));

    if (this.model.get('type') === 'Task') {
      var statusCollection = Teambox.Models.Task.status.status;
      var assignedCollection = Teambox.helpers.tasks.assignedIdCollection(this.model.get('project_id'));

      var dropdown_task_status = new Teambox.Views.DropDown({
          el: this.form.down('.dropdown_task_status')
        , collection: statusCollection
        , className: 'dropdown_task_status'
        , selected: _.detect(statusCollection, function(stat) { return stat.value === self.model.get('status');})
       }).render();

      var dropdown_task_assigned = new Teambox.Views.DropDown({
          el: this.form.down('.dropdown_task_assigned_id')
        , collection: assignedCollection
        , className: 'dropdown_task_assigned_id'
        , selected: _.detect(assignedCollection, function(stat) { return stat.value === self.model.get('assigned_id');})
       }).render();
    }

    if (/\d+$/.test(this.model.url())) {
      this.form.insert({top: new Element('input', {type: 'hidden', name: '_method', value: 'put'})});
    }

    var actions = this.form.down('.subviews');
    // upload area
    actions.insert({bottom: this.upload_area.render().el})

    // watchers box
    actions.insert({bottom: this.watchers.render().el})

    // private elements box
    actions.insert({bottom: this.private_elements.render().el});

    // google docs
    this.form.insert({after: this.google_docs.render().el});

    return this;
  };

  CommentForm.updateFormAttributes = function(project_id) {
   this.form.writeAttribute({
      'accept-charset': 'UTF-8'
    , 'action': this.model.url()
    , 'data-project-id': project_id
    , 'enctype': 'multipart/form-data'
    , 'method': 'POST'
    , 'id': this.simple ? 'new_conversation_form' : ''
    });

    this.form.addClassName("new_comment edit_" + this.model.get('type').toLowerCase());
  };

 

  /* Cleans the form
   *
   * @param {Event} evt
   * @returns false;
   */
  CommentForm.reset = function () {
    // clear comment and reset textarea height
    this.form.down('textarea').update('').setStyle({height: ''}).value = '';
    var preview = this.form.down('.preview');
    if (preview) {
      preview.remove();
    }

    if (this.model.className() === 'Task') {
      this.form.down('.human_hours').value = '';
      this.form.select('.hours_field').invoke('hide');
    }

    this.private_elements.reset();

    this.form.select('.error').invoke('remove');
    this.form.select('.x-pushsession-id').invoke('remove');

    this.el.select('.google_docs_attachment_form_area .fields input').invoke('remove');
    this.el.select('.google_docs_attachment_form_area .file_list li').invoke('remove');
  };

  CommentForm.addComment = function (m, resp, upload) {
    this.reset();

    var comment_attributes = this.model.parseComments(resp);
    //TODO: To be made redundant with APIv2
    this.model.set(_.parseFromAPI(resp), {silent: true});

    if (this.simple) {
      Teambox.collections.threads.add(this.model);
      // TODO: Investigate what we need to do here...
      // Teambox.collections.conversations.add(resp);
    }
    else {
      this.model.trigger('comment:added', comment_attributes, _.clone(Teambox.models.user), this.simple);
    }
  };

  CommentForm.handleError = function (m, resp) {
    if (typeof resp === 'string') {
      var error = resp;
      this.form.down('textarea').up('div').insertOrUpdate('p.error', error);
    }
    else if (resp.errors && resp.errors.length) {
      resp.errors.each(function (error) {
        this.form.down('textarea').up('div').insertOrUpdate('p.error', error.value);
      });
    }

    Teambox.helpers.forms.restoreDisabledInputs(this.el);
  };

  /**
   * Syncs the new comment and triggers `comment:added`
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

    data = _.deparam(this.form.serialize(), true);

    Teambox.helpers.forms.showDisabledInput(this.el);

    //Add the type if it's missing for valiate method
    this.model.save(_.extend(data, {type: this.model.className()}), {
      success: this.addComment.bind(this)
    , error: this.handleError.bind(this)
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
  CommentForm.initUploader = function () {
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
    this.form.down('.add_watchers_box').toggle();
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
    if (this.simple) {
      return;
    }

    var textarea = evt.element()
      , people = Teambox.collections.projects.get(this.model.get('project_id')).getAutocompleterUserNames()
      , container;

    this.form.down('.new_extra').show();

    if (this.autocompleter) {
      this.autocompleter.options.array = people;
    } else {
      container = new Element('div', {'class': 'autocomplete'}).hide();
      textarea.insert({after: container});
      this.autocompleter = new Autocompleter.Local(textarea, container, people, {tokens: [' ']});
    }
  };

  CommentForm.togglePrivateElements = function(event) {
    this.private_elements.toggle(event);
  };

  CommentForm.showGoogleDocs = function(event) {
    this.google_docs.openGoogleDocsList(event);
  };


  CommentForm = _.extend(CommentForm, Teambox.helpers.views);

  // exports
  Teambox.Views.CommentForm = Backbone.View.extend(CommentForm);
}());
