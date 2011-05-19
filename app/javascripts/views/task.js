/*globals Templates*/
(function () {

  var Templates;

  Teambox.Views.Task = Backbone.View.extend({

    tagName: "div"
  , className: "task"
  , template: Templates && Handlebars.compile(Templates.partials.task)

  , events: {
      "click a.name": "expandComments"
    , "click a.edit": "editTitle"
    , "blur form.edit_title input": "updateTitle"
    , "keyup form.edit_title input": "keyupTitle"
    }

  , initialize: function (options) {
      // bindings
      _.bindAll(this, "render");
      this.model.bind('change', this.render);
    }

  , render: function () {
      var el = $(this.el);

      el.update(this.template(this.model.toJSON()));
      el.writeAttribute('id', 'task_' + this.model.id);
      el.writeAttribute('data-task-id', this.model.id);
      el.addClassName(this.getClasses());

      return this;
    }

    // Expand/collapse task comment threads inline
  , expandComments: function (evt) {
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
      return false;
    }

    /* get the classes according to the model's status
     *
     * @return {String} classes
     */
  , getClasses: function () {
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
         ('status_' + task.get('status_name'), true)
         ('status_notopen', !task.get('open?'))
         ('due_on', task.get('due_on') || task.get('closed?'))
         (task.get('assigned') ? 'assigned' : 'unassigned', !task.get('closed?'))
         (task.get('assigned') ? 'user_' + task.get('assigned').user_id : null, true);

      return classes.join(' ');
    }

    // Edit task's title inline
  , editTitle: function (evt) {
      $(this.el).select('a.name, form.edit_title').invoke('toggle');
      $(this.el).down('form.edit_title input').focus();
      return false;
    }

    // Save the edited title when pressing Enter
  , keyupTitle: function (evt) {
      if (evt.keyCode === 13) {
        this.updateTitle(evt);
        return false;
      }
    }

    // Start an AJAX request to update the task's title
  , updateTitle: function (evt) {
      var old = $(this.el).down('a.name').innerHTML
        , now = $(this.el).down('form.edit_title input').value;

      // Update only if the title is dirty
      if (now !== old) {
        $(this.el).down('a.name').update("Saving... (not implemented yet)");
      }

      $(this.el).select('a.name, form.edit_title').invoke('toggle');
      return false;
    }
  });

}());
