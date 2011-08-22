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
  // TODO: Adding the next line because the previous one doesn't work on jQuery
  , 'click .new_comment input[type=submit]'          : 'postComment'
  , 'click a.convert_to_task'      : 'toggleConvertToTask'
  , 'click .date_picker'           : 'showCalendar'
  , 'click a.private_switch'       : 'togglePrivateElements'
  , 'click a.google_doc_icon'      : 'showGoogleDocs'
  , 'focus textarea'               : 'focusTextarea'
  , 'click .cancel'                : 'cancelEditMode'
  };

  CommentForm.initialize = function (options) {
    _.bindAll(this, "render", "addComment", "updateComment");

    this.convert_to_task = options.convert_to_task;
    this.thread = options.thread;
    this.simple = options.simple;
    this.url = options.url;
    this.new_conversation = this.model.get('new_conversation');

    if(!this.new_conversation) {
      this.upload_area = new Teambox.Views.UploadArea({comment_form: this});
    } else {
      this.upload_area = new Teambox.Views.UploadAreaConv();
    }
    this.watchers = new Teambox.Views.Watchers({model: this.model});
    if(!this.new_conversation) {
      this.private_elements = new Teambox.Views.PrivateElements({comment_form: this, model: this.model});
    } else {
      this.private_elements = new Teambox.Views.PrivateElementsConv({comment_form: this, model: this.model});
    }

    this.google_docs = new Teambox.Views.GoogleDocs({comment_form: this});
  };

  /* Updates the comment_form el
   *
   * @returns self;
   */
  CommentForm.render = function () {
    var self = this
    ,   template = this.simple ? this.simple_template : this.template
    ,   people_in_project;

    if (this.new_conversation) {
      people_in_project = Teambox.collections.projects.get(this.model.get('project_id')).get('people').models;
    }

    jQuery(this.el).html(
      template(_.extend({
        view: this
      , editing: this.editing
      , comment_id: this.comment_id
      , project_people: _.select(people_in_project, function(person) {
         return person.id !== Teambox.models.user.id
        })
      }
      , this.model.getAttributes()
      ))
    );

    this.form = this.$('form');
    this.delegateEventsTo(this.events, this.form);

    this.updateFormAttributes(this.model.get('project_id'));

    if (this.model.get('type') === 'Task') {
      var statusCollection = Teambox.Models.Task.status.status;
      var assignedCollection = Teambox.helpers.tasks.assignedIdCollection(this.model.get('project_id'));

      var dropdown_task_status = new Teambox.Views.DropDown({
          el: this.form.find('.dropdown_task_status')
        , collection: statusCollection
        , className: 'dropdown_task_status'
        , selected: _.detect(statusCollection, function(stat) { return stat.value === self.model.get('status');})
       }).render();

      var dropdown_task_assigned = new Teambox.Views.DropDown({
          el: this.form.find('.dropdown_task_assigned_id')
        , collection: assignedCollection
        , className: 'dropdown_task_assigned_id'
        , selected: _.detect(assignedCollection, function(stat) { return stat.value === self.model.get('assigned_id');})
       }).render();
    }

    if (/\d+$/.test(this.model.url())) {
      this.form.prepend( "<input type='hidden' name='_method' value='put'/>" );
    }

    var actions = this.form.find('.subviews');

    actions.append(this.upload_area.render().el);
    actions.append(this.watchers.render().el);
    actions.append(this.private_elements.render().el);
    this.form.after(this.google_docs.render().el);

    if(this.new_conversation) this.form.find('.new_extra').show();

    return this;
  };

  CommentForm.updateFormAttributes = function(project_id) {
   this.form.attr({
      'accept-charset': 'UTF-8'
    , 'action': this.model.url()
    , 'data-project-id': project_id
    , 'enctype': 'multipart/form-data'
    , 'method': 'POST'
    , 'id': this.simple ? 'new_conversation_form' : ''
    });

    this.form.addClass("new_comment edit_" + this.model.get('type').toLowerCase());
  };

 

  /* Cleans the form
   *
   * @param {Event} evt
   * @returns false;
   */
  CommentForm.reset = function () {
    // clear comment and reset textarea height
    this.form.find('textarea').empty().css({height: ''}).val('');
    this.form.find('.preview').remove();

    if (this.model.className() === 'Task') {
      this.form.find('.human_hours').val('');
      this.form.find('.hours_field').hide();
    }

    this.private_elements.reset();

    this.form.find('.error, .x-pushsession-id').remove();
    this.$('.google_docs_attachment_form_area .fields input').remove();
    this.$('.google_docs_attachment_form_area .file_list li').remove();
  };

  CommentForm.addComment = function (m, resp, upload) {
    this.reset();

    var comment_attributes = this.model.parseComments(resp);
    //TODO: To be made redundant with APIv2
    this.model.set(_.parseFromAPI(resp), {silent: true});

    if (this.simple) {
      // TODO: Investigate what we need to do here...
      // Teambox.collections.conversations.add(resp);
    } else if(this.new_conversation) {
      Teambox.collections.conversations.add(resp);
    } else {
      this.model.trigger('comment:added', comment_attributes, _.clone(Teambox.models.user), this.simple);
    }
  };

  CommentForm.updateComment = function (m, resp, upload) {
    this.reset();

    var comment_attributes = this.model.parseComments(resp, this.comment_id);
    //TODO: To be made redundant with APIv2
    this.model.set(_.parseFromAPI(resp), {silent: true});
    this.model.trigger('comment:change', _.extend({id: this.comment_id}, comment_attributes), _.clone(Teambox.models.user));
    this.toggleEditMode();
  };

  CommentForm.handleError = function (m, resp) {
    var error_container = this.form.find('textarea').parent('div');
    if (typeof resp === 'string') {
      var error = resp;
      error_container.html("<p class='error'>"+error+"</p>");
    }
    else if (resp.errors && resp.errors.length) {
      resp.errors.each(function (error) {
        error_container.html("<p class='error'>"+error.value+"</p>");
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

    evt.preventDefault();

    if (this.upload_area.hasFileUploads()) {
      //Uses Teambox.modules.Uploader
      // return this.upload_area.uploadFiles();
      //Uses simple iframe uploading
      return this.upload_area.uploadFile();
    }

    data = _.deparam(this.form.serialize(), true);

    if(data.watchers) data.watchers = JSON.stringify(data.watchers.split(','));

    Teambox.helpers.forms.showDisabledInput(this.el);

    //Add the type if it's missing for validate method
    this.model.save(_.extend(data, {type: this.model.className()}), {
      success: this.editing ? this.updateComment : this.addComment
    , error: this.handleError.bind(this)
    , url: this.url
    });

    return false;
  };

  /* Toggle the attach files area
   *
   * @param {Event} evt
   */
  CommentForm.toggleAttach = function (evt) {
    evt && evt.preventDefault();

    //TODO: Find a better place to init the uploader
    //Currently, plupload checks for file list container in DOM sw we
    //need to be sure it exists in DOM when intiting the uploader
    //Disabling plupload
    // this.initUploader();

    var upload_area = this.$('.upload_area');
    upload_area.toggle();

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
    evt.preventDefault();
    this.$('.hours_field').toggle().find('input').focus();
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
    evt.preventDefault();
    this.form.find('.add_watchers_box').toggle();
  };

  /* Displays the calendar
   *
   * @param {Event} evt
   */
  CommentForm.showCalendar = function (evt) {
    evt.preventDefault();
    var el = jQuery(evt.currentTarget);

    new Teambox.modules.CalendarDateSelect(el.find('input')[0], el.find('span')[0], {
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
  CommentForm.focusTextarea = function (evt, el) {
    if (this.simple) { return; }

    var textarea = evt ? jQuery(evt.currentTarget) : el
      , people = Teambox.collections.projects.get(this.model.get('project_id')).getAutocompleterUserNames()
      , container;

    this.form.find('.new_extra').show();

    if (this.autocompleter) {
      this.autocompleter.options.array = people;
    } else {
      container = jQuery("<div class='autocomplete' style='display:none'></div>");
      textarea.after(container);
      // Mixing prototype and jQuery because of the autocompleter...
      this.autocompleter = new Autocompleter.Local(textarea[0], container[0], people, {tokens: [' ']});
    }
  };

  CommentForm.togglePrivateElements = function(event) {
    this.private_elements.toggle(event);
  };

  CommentForm.showGoogleDocs = function(event) {
    this.google_docs.openGoogleDocsList(event);
  };

  CommentForm.cancelEditMode = function(event) {
    this.toggleEditMode(event);
    this.thread.cancelEditMode();
  };

  CommentForm.toggleEditMode = function(event, comment_id) {
    event && event.preventDefault();

    this.editing = !this.editing;
    this.form.toggleClass('editing');
    this.comment_id = comment_id;
    this.render();
  };

  CommentForm.editComment = function(comment) {
    this.toggleEditMode(false, comment.id);
    var textarea = this.$('textarea')
    ,   comment_body = comment.get('body');

    this.focusTextarea(false, textarea);
    textarea.focus().val(comment_body).select();
    Teambox.helpers.views.scrollTo(textarea);
  };


  CommentForm = _.extend(CommentForm, Teambox.helpers.views);

  // exports
  Teambox.Views.CommentForm = Backbone.View.extend(CommentForm);

}());
