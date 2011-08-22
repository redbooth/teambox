(function () {

  var Task = { tagName: 'div'
             , className: 'task'
             , template: Teambox.modules.ViewCompiler('partials.task')
             };

  Task.events = {
    'click a.name': 'toggleComments'
  , 'click a.edit': 'editTitle'
  , 'blur form.edit_title input': 'updateTitle'
  , 'keyup form.edit_title input': 'keyupTitle'
  };

  Task.initialize = function (options) {
    var self = this;

    // bindings
    _.bindAll(this, 'render');

    this.dragndrop = options.dragndrop;
    this.model.set(
      { task_list: Teambox.collections.tasks_lists.get(this.model.get('task_list_id')) },
      { silent: true });
    this.model.attributes.is_task = this.model.get('type') === 'Task';
    this.model.attributes.is_conversation = this.model.get('type') === 'Conversation';

    this.model.bind('change', this.render);
    this.model.get('task_list').bind('change', this.render);
    this.model.bind('destroy', function() { self.el.remove(); });
  };

  /**
   * Updates the element using the template
   *
   * @return self
   */
  Task.render = function () {
    jQuery(this.el)
      .html(this.template(this.model.getAttributes()))
      .attr({ 'id': 'task_' + this.model.id
            , 'data-task-id': this.model.id });

    if (this.dragndrop && !this.model.isArchived()) {
      this.$('.taskStatus').prepend(
        "<img alt='Drag' class='task_drag' src='/images/drag.png'>"
      );
    }

    jQuery(this.el).addClass(this.model.getClasses());
    this.$('.thread_child').append( (new Teambox.Views.CommentForm({
      model: (new Teambox.Models.Thread(this.model.attributes))
    , controller: this.controller
    })).render().el );

    return this;
  };

  /**
   * Expand/collapse task comment threads inline
   *
   * @param {Event} evt
   */
  Task.toggleComments = function (evt) {
    var thread_block = this.$('.thread_child');

    evt.preventDefault();

    if (jQuery(this.el).hasClass('expanded')) {
      thread_block.slideUp(300);
      this.$('.expanded_actions').fadeOut(300);
    } else {
      thread_block.slideDown(300);
      this.$('.expanded_actions').fadeIn(300);
      Date.format_posted_dates();

      // TODO: ?
      // Task.insertAssignableUsers();
    }

    jQuery(this.el).toggleClass('expanded');
  };

  // Edit task's title inline
  Task.editTitle = function (evt) {
    this.$('a.name, form.edit_title').toggle();
    this.$('form.edit_title input:first').focus();
    evt.preventDefault();
  };

  // Save the edited title when pressing Enter
  Task.keyupTitle = function (evt) {
    if (evt.keyCode === 13) {
      this.updateTitle(evt);
      evt.preventDefault();
    }
  };

  // Start an AJAX request to update the task's title
  Task.updateTitle = function(evt) {
    var self = this;
    var element = jQuery(this.el);
    var title = element.find('a.name');
    var old = element.find('a.name').text();
    var input = element.find('form.edit_title input');
    var now = input.val();

    var toggleForm = function() {
      element.find('a.name, form.edit_title').toggle();
    };

    // Update only if the title is dirty
    if( now !== old ) {
      toggleForm();
      self.model.set({name: now});

      title = element.find('a.name');
      title.html(input.attr('data-disable-with'));
      title.addClass('loading');

      self.model.save(false, {
        success: function() {
          title.removeClass('loading');
          self.model.change();
        },
        error: function(){
          title.removeClass('loading');
          toggleForm();
        }
      });
    }
    evt.preventDefault();
  };

  Task.disableFormSubmit = function (e) {
    e.preventDefault();
  };

  // exports
  Teambox.Views.Task = Backbone.View.extend(Task);
}());
