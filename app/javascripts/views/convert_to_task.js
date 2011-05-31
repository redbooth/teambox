(function () {

  var ConvertToTask = { tagName: 'div'
                      , className: 'convert_to_task'
                      , template: Handlebars.compile(Templates.partials.convert_to_task)
                      };

  ConvertToTask.events = {
    'ajax:success form.edit_conversation.convert-to-task': 'onSubmited'
  , 'ajax:failure form.edit_conversation.convert-to-task': 'onFailure'
  };

  ConvertToTask.initialize = function (options) {
    _.bindAll(this, "render");
  };

  ConvertToTask.render = function () {
    $(this.el).setStyle({display: 'none'});
    $(this.el).update(this.template());
    return this;
  };

  ConvertToTask.toggle = function () {
    var el = this.el
      , _method = el.select('input[name=_method]')[0]
      , submit = el.select('input[type=submit]')[0];

    el.toggle();

    el.select('select,input').each(function (e) {
      e.disabled = !e.disabled;
    });

    // reenable convert to task submit button
    // (If we previously submit a comment from a conversation
    // the default rails action for elements with disable-with disables it)
    if (!el.down('select').disabled) {
      submit.disabled = false;
    }

    el.select('#conversation_task_list_id').each(function (select) {
      if (select.options[0].value === '') {
        var project_id = select.up('form').getAttribute('data-project-id')
          , task_lists = new Teambox.Collections.TaskLists({project_id: project_id});

        task_lists.fetch({
          success: function (collection, response) {
            select.options.length = 0;
            select.options.add(new Option("Inbox", ''));
            collection.models.each(function (taskList) {
              select.options.add(new Option(taskList.get('name'), taskList.id));
            });
          }
        });
      }
    });
  };

  // TODO: implement
  ConvertToTask.onSubmited = function () {
    // var person = this.el.select('conversation_assigned_id')[0].getValue()
    //   , task_count = +$('open_my_tasks').innerHTML
    //   , is_assigned_to_me = my_projects[person];

    // if (is_assigned_to_me) {
    //   task_count += 1;
    //   $('open_my_tasks').update(task_count);
    // }

    // if ($$('.conversation_header').length === 1) {
    //   document.location.href = e.memo.responseText;
    // } else {
    //   e.element().up('.thread').update(e.memo.responseText).highlight({ duration: 2 });
    //   Task.insertAssignableUsers();
    // }
  };

  // TODO: implement
  ConvertToTask.onFailure = function () {
    // var message = $H(e.memo.responseJSON)
    // message.each(function (error) {
    //   form.down('#conversation_name').insert({after: "<p class='error'>" + message + "</p>"})
    // })
  };

  // exports
  Teambox.Views.ConvertToTask = Backbone.View.extend(ConvertToTask);

}());
