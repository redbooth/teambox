(function () {

  var CommentForm = { tagName: 'form'
                    , className: 'new_comment'
                    , template: Handlebars.compile(Templates.partials.comment_form)
                    };

  CommentForm.events = {
    'click a.attach_icon'               : 'toggleAttach'
  , 'click a.add_hours_icon'            : 'toggleHours'
  , 'click a.add_watchers'              : 'toggleWatchers'
  , 'focusin textarea'                  : 'focusTextarea'
  , 'submit .new_comment'               : 'postComment'
  , 'click span.convert_to_task a'      : 'toggleConvertToTask'
  , 'click div.convert_to_task a.cancel': 'toggleConvertToTask'
  };

  CommentForm.initialize = function (options) {
    _.bindAll(this, "render");

    this.convert_to_task = options.convert_to_task;
    // FIXME: bind to changes
  };

  CommentForm.render = function () {

    this.el.writeAttribute({
      'accept-charset': 'UTF-8'
    , 'action': this.model.comments_url()
    , 'data-project-id': this.model.get('project_id')
    , 'enctype': 'multipart/form-data'
    , 'method': 'post'
    });

    this.el.addClassName("edit_" + this.model.get('type').toLowerCase());

    this.el.update(this.template(this.model.getAttributes()));

    // select status
    (new Teambox.Views.SelectStatus({
      el: this.el.select('#task_status')[0]
    , selected: this.model.get('status')
    })).render();

    this.el.down('.actions')
      // upload area
      .insert({before: (new Teambox.Views.UploadArea({comment_form: this})).render().el})
      // watchers box
      .insert({before: (new Teambox.Views.Watchers({model: this.model})).render().el});

    return this;
  };

  /* Cleans the form
   *
   * @param {Event} evt
   * @returns false;
   */
  CommentForm.reset = function () {
    var form = this.el
      , hours = form.down('input[name*="[human_hours]"]');

    // clear comment and reset textarea height
    form.down('textarea[name*="[body]"]').setValue('').setStyle({height: ''});

    // clear populated file uploads
    form.select('input[type=file]').each(function (input) {
      if (input.getValue()) {
        input.remove();
      }
    });

    if (hours) {
      hours.setValue('');
    }

    form.select('.hours_field, .upload_area').invoke('hide');
    form.select('.error').invoke('remove');
    form.select('.google_docs_attachment .fields input').invoke('remove');
    form.select('.google_docs_attachment .file_list li').invoke('remove');
  };

  /* Syncs the new comment and triggers `comment:added`
   *
   * @param {Event} evt
   * @returns false;
   */
  CommentForm.postComment = function (evt) {
    var self = this
      , body = this.el.select('textarea')[0].value;

    evt.stop();

    if (this.hasFileUploads()) {
      return this.uploadFile();
    }

    (new Teambox.Models.Comment({
      parent_url: this.model.url()
    , body: body
    })).save(null, {
      success: function (model, resp) {
        self.reset();
        self.model.trigger('comment:added', resp, _.clone(Teambox.models.user));
      }
    , failure: function (model, resp) {
        resp.errors.each(function (error) {
          self.el.down('div.text_area').insertOrUpdate('p.error', error.value);
        })
      }
    });
    return false;
  };

  /* Toggle the attach files area
   *
   * @param {Event} evt
   */
  CommentForm.toggleAttach = function (evt) {
    evt.stop();
    $(this.el).down('.upload_area').toggle().highlight();
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
    evt.stop();
    this.convert_to_task.toggle();
    this.el.toggle();
  };

  /* Toggle the "Add Watchers" area
   *
   * @param {Event} evt
   */
  CommentForm.toggleWatchers = function (evt) {
    evt.stop();
    this.el.down('.add_watchers_box').toggle();
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

  /* checks if the form has file uploads
   *
   * @return {Boolean}
   */
  CommentForm.hasFileUploads = function () {
    return this.el.select('input[type=file]').any(function (input) {
      return input.getValue();
    });
  };

  /* checks if the form has empty file uploads
   *
   * @return {Boolean}
   */
  CommentForm.hasEmptyFileUploads = function () {
    return this.el.select('input[type=file]').any(function (input) {
      return !input.getValue();
    });
  };

  /* creates an iframe and uploads a file
   */
  CommentForm.uploadFile = function () {
    var self = this
      , iframe_id = 'file_upload_iframe' + Date.now()
      , iframe = new Element('iframe', {id: iframe_id, name: iframe_id}).hide()
      , authToken = $$('meta[name=csrf-token]').first().readAttribute('content')
      , authParam = $$('meta[name=csrf-param]').first().readAttribute('content');

    function callback() {

      // contentDocument doesn't work in IE (7)
      var iframe_body = (iframe.contentDocument || iframe.contentWindow.document).body
        , extra_input = self.el.down('input[name=iframe]');

      // TODO: Parse the response and add the comment client side

      iframe.remove();
      self.el.target = null;
      if (extra_input) {
        extra_input.remove();
      }
    }

    $(document.body).insert(iframe);
    this.el.target = iframe_id;
    this.el.insert(new Element('input', {type: 'hidden', name: 'iframe', value: true}));

    if (this.el[authParam]) {
      this.el[authParam].value = authToken;
    } else {
      this.el.insert(new Element('input', {type: 'hidden', name: authParam, value: authToken}).hide());
    }

    // for IE (7)
    iframe.onreadystatechange = function () {
      if (this.readyState === 'complete') {
        callback();
      }
    };

    // non-IE
    iframe.onload = callback;

    // we may have cancelled xhr, but we still need to trigger form submit manually
    this.el.submit();
  };

  // exports
  Teambox.Views.CommentForm = Backbone.View.extend(CommentForm);
}());
