(function () {

  var ConvertToTask = { tagName: 'form'
                      , className: 'convert_to_task'
                      , template: Teambox.modules.ViewCompiler('partials.convert_to_task')
                      };

  ConvertToTask.events = {
    'submit': 'convertToTask'
  , 'click form.convert_to_task a.cancel': 'toggle'
  };

  ConvertToTask.initialize = function (options) {
    _.bindAll(this, "render");

    this.comment_form = options.comment_form;
    this.project = Teambox.collections.projects.get(this.model.get('project_id'));
  };

  ConvertToTask.render = function () {
    var select;

    this.el.writeAttribute({
      'accept-charset': 'UTF-8'
    , 'action': this.model.convertToTaskUrl()
    , 'method': 'POST'
    });

    this.el.hide();
    this.el.update(this.template());

    // select status
    (new Teambox.Views.SelectStatus({
      el: this.el.select('#conversation_status')[0]
    })).render();

    // select assigned
    (new Teambox.Views.SelectAssigned({
      el: this.el.select('#conversation_assigned_id')[0]
    , selected: null
    , project: this.project
    })).render();

    select = this.el.select('#conversation_task_list_id')[0];
    this.project.get('task_lists').models.each(function (task_list) {
      select.options.add(new Option(task_list.get('name'), task_list.id));
    });

    return this;
  };

  /* Displays the form and fills the project select
   *
   * @param {Event} evt
   */
  ConvertToTask.toggle = function (evt) {
    evt.stop();

    this.el.toggle();
    this.comment_form.el.toggle();
  };

  /* Calls to convert to task API
   *
   * @param {Event} evt
   * @returns false;
   */
  ConvertToTask.convertToTask = function (evt) {
    var self = this;

    evt.stop();
    this.model.convertToTask(
      this.el.serialize(true)
    , function onSuccess(transport) {
        var task = new Teambox.Models.Task({ id: transport.responseJSON.id
                                           , project_id: transport.responseJSON.project_id
                                           });

        window.location.hash = '#!' + task.public_url();
        // var person = this.el.select('conversation_assigned_id')[0].getValue()
        //   , task_count = +$('open_my_tasks').innerHTML
        //   , is_assigned_to_me = my_projects[person];

        // if (is_assigned_to_me) {
        //   task_count += 1;
        //   $('open_my_tasks').update(task_count);
        // }

        // if ($$('.conversation_header').length === 1) {
        //   document.location.href = task.url();
        // } else {
        //   e.element().up('.thread').update(e.memo.responseText).highlight({ duration: 2 });
        //   Task.insertAssignableUsers();
        // }
      }
    , function onError(transport) {
        var message = transport.responseJSON;
        message.errors.each(function (error) {
          self.el.down('#conversation_name').insert({after: "<p class='error'>" + error.message + "</p>"});
        })
      }
    );
    return false;
  };

  // exports
  Teambox.Views.ConvertToTask = Backbone.View.extend(ConvertToTask);

}());
