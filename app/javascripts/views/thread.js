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
  , 'click a.edit': 'editComment'
  , 'click a.delete': 'deleteComment'
  , 'mouseover .comment .actions_menu': 'applyCommentActionRules'
  };

  Thread.initialize = function (options) {
    _.bindAll(this, "render");

    this.model.attributes.is_task = this.model.get('type') === 'Task';
    this.model.attributes.is_conversation = this.model.get('type') === 'Conversation';
    this.model.bind('comment:added', Thread.addComment.bind(this));
    this.model.bind('comment:change', Thread.updateComment.bind(this));
    this.model.bind('comment:added', Thread.updateThreadAttributes.bind(this));

    var Views = Teambox.Views;
    this.convert_to_task = new Views.ConvertToTask({model: this.model});
    this.comment_form = new Views.CommentForm({
          model: this.model
        , convert_to_task: this.convert_to_task
        , controller: this.controller
        , thread: this
    });

    this.initializeComments();

  };

  Thread.initializeComments = function() {
    var options = {project_id: this.model.get('project_id')}
    ,   comments = [];

    options[this.model.get('type').toLowerCase() + '_id'] = this.model.id;
    this.comments = new Teambox.Collections.Comments(this.model.attributes.recent_comments, options);
  };


  /* sets the target attribute to '_blank'
   *
   * @param {Event} evt
   */
  Thread.reloadComments = function (evt) {
    evt.preventDefault();

    var el = jQuery(evt.currentTarget)
      , self = this
      , options = {project_id: this.model.get('project_id')}
      , comments;

    options[this.model.get('type').toLowerCase() + '_id'] = this.model.id;
    comments = new Teambox.Collections.Comments([],options);
    el.html("<img src='/images/loading.gif' alt='Loading' />");

    comments.fetch({
      success: function (collection) {
        var html = '';
        _.each(collection.models.reverse(), function (model) {
          html += self.comment_template(model.attributes);
        });
        el.parent('.comments').html(html).slideDown(500);
      }
    });
  };

  /* Loads up the comment in the comment form and
   * switches the comment form to edit mode.
   *
   * @param {Event} evt
   */
  Thread.editComment = function (event) {
    var comment = jQuery(event.currentTarget).parent('.comment')
    , comment_id = parseInt(comment.attr('data-id'), 10)
    , comment = this.comments.get(comment_id);
    this.comment_form.editComment(comment);
    this.toggleCommentEditMode(comment_id);
  };

  Thread.toggleCommentEditMode = function(comment_id) {
    var comments = this.$('.comments .comment')
    ,   comment = this.$('.comment[data-id=' + comment_id + ']');
    _.each(comments, function(c) {
      if (c.getAttribute('data-id') !== comment_id.toString()) {
        c.toggleClass('editing');
      }
    });
  };

  Thread.cancelEditMode = function() {
    var comments = this.$('.comments .comment').removeClass('editing');
  };

  /* alerts the user and deletes the comment if dangerous
   *
   * @param {Event} evt
   */
  Thread.deleteComment = function (evt) {
    var element = jQuery(evt.currentTarget).parent('.comment')
    , comment_id = parseInt(element.attr('data-id'), 10)
    , comment;

    comment = this.comments.get(comment_id);
    comment.set({parent_url: this.model.url()}, {silent: true});
    this.comments.remove(comment, {silent: true});

    evt.preventDefault();

    if (confirm('Are you sure?')) {
      comment.destroy({
        success: function (model) { element.hide(); }
      });
    }
  };

  /* sets the target attribute to '_blank'
   *
   * @param {Event} evt
   */
  Thread.setTargetBlank = function (evt) {
    jQuery(evt.currentTarget).attr('target', '_blank');
  };

  /* adds a comment to the thread
   *
   * @param {Object} response
   * @param {Object} user
   */
  Thread.addComment = function (comment, user, simple) {
    console.log("add comment");
    if (simple) return;

    if (user) comment.user = user.attributes;

    var el = this.comment_template(comment);

    this.$('.comments').append(el);
    //  el.highlight(1000);

    // update excerpt
    var excerpt = this.$('.comment_header .excerpt');
    if (excerpt) {
      excerpt.html('<strong>' + comment.user.first_name + ' ' + comment.user.last_name
                  + '</strong> ' + comment.body);
    }

    this.comments.add(comment, {silent: true});

    // TODO: backbonize this [leftovers from comment.js]
    //Task.insertAssignableUsers();
    //my_user.stats.conversations++;
    //document.fire("stats:update");
  };

  /* Updates a comment in the thread
   *
   * @param {Object} comment attributes
   */
  Thread.updateComment = function (comment, user) {
    if (user) {
      comment.user = user.attributes;
    }

    var markup = this.comment_template(comment)
    ,   el = this.$('.comment[data-id=' + comment.id + ']');

    el.replaceWith(markup);

    this.toggleCommentEditMode(comment.id);

    //Update comment model attributes in comments collection
    var model = this.comments.get(comment.id);
    model.set(comment, {silent: true});

    //Refind
    el = this.$('.comment[data-id=' + comment.id + ']');
    Teambox.helpers.views.scrollTo(el);
    //setTimeout(function() {el.highlight({duration: 1});}, 1000);

    // update excerpt
    var excerpt = this.$('.comment_header .excerpt');
    if (excerpt) {
      excerpt.html('<strong>' + comment.user.first_name + ' ' + comment.user.last_name
                  + '</strong> ' + comment.body);
    }
  };

  /* updates thread tag attributes
   *
   * @return {Object} self
   */
  Thread.updateThreadAttributes = function(comment, user, simple) {
    if (simple) { return; }
    // Add data attributes to the DOM.
    jQuery(this.el).attr({
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
    var attributes = this.model.getAttributes();
    attributes.recent_comments = attributes.recent_comments.reverse();
    jQuery(this.el).html(this.template(attributes));

    // Insert the comment form at bottom of the thread element

    this.comment_form.el = this.$('div.new_comment_wrap');
    this.comment_form.render();

    if (this.model.isConversation()) {
      this.$('div.new_comment_wrap').append(this.convert_to_task.render().el);
    }

    return this;
  };

  Thread.applyCommentActionRules = function(event) {
    var actions_menu = jQuery(event.currentTarget);
    if (!actions_menu.hasClass('actions_menu')) {
      actions_menu = actions_menu.parent('.actions_menu');
    }

    var comment = actions_menu.parent('.comment')
    ,   current_user = Teambox.models.user
    ,   projects = Teambox.collections.projects.models
    ,   user_id = parseInt(comment.attr('data-user'), 10)
    ,   project_id = parseInt(comment.attr('data-project'), 10)
    ,   timestamp = parseInt(comment.attr('data-editable-before'), 10);

    // My own comments: I can modify them, a later filter will ensure that only for 15 minutes
    if(user_id == current_user.id) {
      actions_menu.$('.edit').show();
    }

    // Projects where I'm admin: I can destroy comments at any time
    var projects_im_admin = Teambox.helpers.projects.getMyAdminProjects(current_user.id);
    if(projects_im_admin.include(project_id)) {
      actions_menu.$('.edit, .delete').show();
    }

    // Disable editing comments 15 minutes after posting them
    var now = new Date()
    ,   editableBefore = new Date(parseInt(timestamp));

    if (now >= editableBefore) {
      _.each(['edit', 'delete'], function(className) {

         var link = actions_menu.$('a.' + className);
         if (link) {
           var message = link.attr('data-un' + className + 'able-message');
           link.replaceWith("<span class="+className+">"+message+"</span>");
         }
      });
    }
  };

  // exports
  Teambox.Views.Thread = Backbone.View.extend(Thread);
}());
