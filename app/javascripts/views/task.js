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
    // bindings
    _.bindAll(this, 'render');

    this.dragndrop = options.dragndrop;
    this.model.bind('change', this.render);
  };

  /**
   * Updates the element using the template
   *
   * @return self
   */
  Task.render = function () {
    this.el.update(this.template(this.model.getAttributes()));
    this.el.writeAttribute('id', 'task_' + this.model.id);
    this.el.writeAttribute('data-task-id', this.model.id);


    if (this.dragndrop && !this.model.isArchived()) {
      this.el.down('.taskStatus').insert({
        top: new Element('img', {alt: 'Drag', 'class': 'task_drag', src: '/images/drag.png'})
      });
    }

    this.el.addClassName(this.model.getClasses());
    this.el.down('.thread').insert({bottom: (new Teambox.Views.CommentForm({
      model: (new Teambox.Models.Thread(this.model.attributes))
    , controller: this.controller
    })).render().el});

    return this;
  };

  /**
   * Expand/collapse task comment threads inline
   *
   * @param {Event} evt
   */
  Task.toggleComments = function (evt) {
    var thread_block = this.el.down('.thread'), foo;

    evt.stop();

    if (this.el.hasClassName('expanded')) {
      foo = new Effect.BlindUp(thread_block, {duration: 0.3});
      foo = new Effect.Fade(this.el.down('.expanded_actions'), {duration: 0.3});
    } else {
      foo = new Effect.BlindDown(thread_block, {duration: 0.3});
      foo = new Effect.Appear(this.el.down('.expanded_actions'), {duration: 0.3});
      Date.format_posted_dates();

      // TODO: ?
      // Task.insertAssignableUsers();
    }

    this.el.toggleClassName('expanded');
  };

  // Edit task's title inline
  Task.editTitle = function (evt) {
    $(this.el).select('a.name, form.edit_title').invoke('toggle');
    $(this.el).down('form.edit_title input').focus();
    return false;
  };

  // Save the edited title when pressing Enter
  Task.keyupTitle = function (evt) {
    if (evt.keyCode === 13) {
      this.updateTitle(evt);
      return false;
    }
  };

  // Start an AJAX request to update the task's title
  Task.updateTitle = function(evt) {
    var self = this;
    var element = $(this.el);
    var title = element.down('a.name');
    var old = element.down('a.name').innerHTML;
    var input = element.down('form.edit_title input');
    var now = input.value;

    var toggleForm = function() {
      element.select('a.name, form.edit_title').invoke('toggle');
    };

    // Update only if the title is dirty
    if( now !== old ) {
      toggleForm();
      self.model.set({name: now});

      title = element.down('a.name');
      title.update(input.getAttribute('data-disable-with'));
      title.addClassName('loading');

      self.model.save(false, {
        success: function() {
          title.removeClassName('loading');
          self.model.change();
        },
        error: function(){
          title.removeClassName('loading');
          toggleForm();
        }
      });
    }
    return false;
  };

  Task.disableFormSubmit = function (e) {
    Event.stop(e);
    return false;
  };

  // exports
  Teambox.Views.Task = Backbone.View.extend(Task);
}());
