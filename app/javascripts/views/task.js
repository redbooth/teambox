(function () {

  var Task = { tagName: 'div'
             , className: 'task'
             , template: Teambox.modules.ViewCompiler('partials.task')
             };

  Task.events = {
    'click a.name': 'expandComments'
  , 'click a.edit': 'editTitle'
  , 'blur form.edit_title input': 'updateTitle'
  , 'keyup form.edit_title input': 'keyupTitle'
  };

  Task.initialize = function (options) {
    // bindings
    _.bindAll(this, 'render');
    this.model.bind('change', this.render);
  };

  /* updates the element using the template
   *
   * @return self
   */
  Task.render = function () {
    this.el.update(this.template(this.model.getAttributes()));
    this.el.writeAttribute('id', 'task_' + this.model.id);
    this.el.writeAttribute('data-task-id', this.model.id);
    this.el.addClassName(this.getClasses());

    return this;
  };

  /* Expand/collapse task comment threads inline
   *
   * @param {Event} evt
   */
  Task.expandComments = function (evt) {
    var task = $(this.el)
      , thread_block = task.down('.thread'), foo;

    if (task.hasClassName('expanded')) {
      foo = new Effect.BlindUp(thread_block, {duration: 0.3});
      foo = new Effect.Fade(task.down('.expanded_actions'), {duration: 0.3});
    } else {
      foo = new Effect.BlindDown(thread_block, {duration: 0.3});
      foo = new Effect.Appear(task.down('.expanded_actions'), {duration: 0.3});
      Date.format_posted_dates();

      // TODO: ?
      Task.insertAssignableUsers();
    }

    task.toggleClassName('expanded');
  };

  /* get the classes according to the model's status
   *
   * @return {String} classes
   */
  Task.getClasses = function () {
    var task = this.model
      , one_week = 1000 * 60 * 60 * 24 * 7
      , classes = [];

    function add(klass, stat) {
      if (stat && klass) {
        classes.push(klass);
      }
      return add;
    }

    add('due_today', task.is_due_today())
       ('due_tomorrow', task.is_due_tomorrow())
       ('due_week', task.is_due_in(one_week))
       ('due_2weeks', task.is_due_in(one_week * 2))
       ('due_3weeks', task.is_due_in(one_week * 3))
       ('due_month', task.is_due_in(one_week * 4))
       ('overdue', task.is_overdue())
       ('unassigned_date', !task.get('due_on'))
       ('status_' + task.get('status'), true)
       ('status_notopen', !task.get('open?'))
       ('due_on', task.get('due_on') || task.get('closed?'))
       (task.get('task_list_id') ? 'task_list_' + task.get('task_list_id') : '', task.get('task_list_id'))
       (task.get('assigned') ? 'assigned' : 'unassigned', !task.get('closed?'))
       (task.get('assigned') ? 'user_' + task.get('assigned').user_id : null, true);

    return classes.join(' ');
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
