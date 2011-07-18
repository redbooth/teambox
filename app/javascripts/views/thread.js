// This view renders a Conversation or Task as a thread
(function () {

  var Thread = { tagName: 'div'
               , className: 'thread'
               , template: Teambox.modules.ViewCompiler('partials.thread')
               , comment_template: Teambox.modules.ViewCompiler('partials.comment')
               };

  Thread.events = {
    'mouseover .textilized a': 'setTargetBlank'
  , 'click .thread .comments .more_comments a': 'reloadComments'
  , 'click a.delete': 'deleteComment'
  , 'click a.google_doc_icon'      : 'showGoogleDocs'
  };

  Thread.initialize = function (options) {
    _.bindAll(this, "render");


    this.model.attributes.is_task = this.model.get('type') === 'Task';
    this.model.bind('comment:added', Thread.addComment.bind(this));
    this.model.bind('comment:added', Thread.updateThreadAttributes.bind(this));

    var Views = Teambox.Views;
    this.convert_to_task = new Views.ConvertToTask({model: new Teambox.Models.Conversation(this.model.attributes)});
    this.comment_form = new Views.CommentForm({
          model: this.model
        , convert_to_task: this.convert_to_task
        , controller: this.controller
        , thread: this
    });
    this.google_docs = new Teambox.Views.GoogleDocs({comment_form: this.comment_form});
  };

  /* Cleans the thread
   *
   * @param {Event} evt
   * @returns false;
   */
  Thread.reset = function () {
    this.el.select('.google_docs_attachment_form_area .fields input').invoke('remove');
    this.el.select('.google_docs_attachment_form_area .file_list li').invoke('remove');
  };

  /* sets the target attribute to '_blank'
   *
   * @param {Event} evt
   */
  Thread.reloadComments = function (evt) {
    evt.stop();

    var el = evt.element()
      , self = this
      , options = {project_id: this.model.get('project_id')}
      , comments;

    options[this.model.get('type').toLowerCase() + '_id'] = this.model.id;
    comments = new Teambox.Collections.Comments(options);
    el.update("<img src='/images/loading.gif' alt='Loading' />");

    comments.fetch({
      success: function (collection) {
        var html = '';
        _.each(collection.models.reverse(), function (model) {
          html += self.comment_template(model.attributes);
        });
        el.up('.comments').update(html).blindDown({duration: 0.5});
      }
    });
  };

  /* alerts the user and deletes the comment if dangerous
   *
   * @param {Event} evt
   */
  Thread.deleteComment = function (evt) {
    var element = evt.element().up('.comment'), comment;

    comment = new Teambox.Models.Comment({id: element.readAttribute('data-id'), parent_url: this.model.url()});

    evt.stop();

    if (confirm('Are you sure?')) {
      comment.destroy({
        success: function (model) {
          element.hide();
        }
      });
    }
  };

  /* sets the target attribute to '_blank'
   *
   * @param {Event} evt
   */
  Thread.setTargetBlank = function (evt) {
    evt.element().writeAttribute('target', '_blank');
  };

  /* adds a comment to the thread
   *
   * @param {Object} response
   * @param {Object} user
   */
  Thread.addComment = function (comment, user, simple) {
    if (simple) { return; }

    if (user) {
      comment.user = user.attributes;
    }

    var el = this.comment_template(comment);

    this.el.select('.comments')[0]
      .insert({bottom: el})
      .childElements()
      .last()
      .highlight({duration: 1});

    // update excerpt
    var excerpt = this.el.down('.comment_header .excerpt');
    if (excerpt) {
      excerpt.update('<strong>' + comment.user.first_name + ' ' + comment.user.last_name
                   + '</strong> ' + comment.body);
    }

    // TODO: backbonize this [leftovers from comment.js]
    //Task.insertAssignableUsers();
    //my_user.stats.conversations++;
    //document.fire("stats:update");
  };

  /* updates thread tag attributes
   *
   * @return {Object} self
   */
  Thread.updateThreadAttributes = function(comment, user, simple) {
    if (simple) { return; }
    // Add data attributes to the DOM.
    this.el.writeAttribute({
      'className': this.model.get('is_private') ? 'thread private' : 'thread'
    , 'data-class': this.model.get('type').toLowerCase()
    , 'data-id': this.model.get('id')
    , 'data-project-id': this.model.get('project_id')
    });
  };


  /* updates thread el using a template
   *
   * @return {Object} self
   */
  Thread.render = function () {
    this.updateThreadAttributes();
    this.convert_to_task.comment_form = this.comment_form;

    // Prepare the thread DOM element
    this.el.update(this.template(this.model.getAttributes()));

    // Insert the comment form at bottom of the thread element
    this.el.down('div.new_comment_wrap').insert({bottom: this.comment_form.render().el});
    if (this.model.isConversation()) {
      this.el.down('div.new_comment_wrap').insert({bottom: this.convert_to_task.render().el});
    }
    // google docs
    // Because comment_form view's el is the actual form tag, 
    // the google docs view needs to be inserted at the thread level
    this.el.down('div.new_comment_wrap').insert({bottom: this.google_docs.render().el});

    return this;
  };

  Thread.showGoogleDocs = function(event) {
    this.google_docs.openGoogleDocsList(event);
  };

  // exports
  Teambox.Views.Thread = Backbone.View.extend(Thread);
}());
