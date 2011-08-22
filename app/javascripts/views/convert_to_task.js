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

    jQuery(this.el)
      .attr({
          'accept-charset': 'UTF-8'
        , 'action': this.model.convertToTaskUrl()
        , 'method': 'POST' })
      .hide()
      .html(this.template());

    var statusCollection = Teambox.Models.Task.status.status
    ,   assignedCollection = Teambox.helpers.tasks.assignedIdCollection(this.model.get('project_id'))
    ,   taskListCollection = Teambox.helpers.task_lists.taskListsCollection(this.model.get('project_id'));

    var dropdown_task_task_list = new Teambox.Views.DropDown({
        el: this.$('.dropdown_conversation_task_list_id')
      , collection: taskListCollection
      , className: 'dropdown_conversation_task_list_id'
     }).render();

    var dropdown_task_status = new Teambox.Views.DropDown({
        el: this.$('.dropdown_conversation_status')
      , collection: statusCollection
      , className: 'dropdown_conversation_status'
     }).render();

    var dropdown_task_assigned = new Teambox.Views.DropDown({
        el: this.$('.dropdown_conversation_assigned_id')
      , collection: assignedCollection
      , className: 'dropdown_conversation_assigned_id'
     }).render();

    return this;
  };

  /* Displays the form and fills the project select
   *
   * @param {Event} evt
   */
  ConvertToTask.toggle = function (evt) {
    evt.preventDefault();

    jQuery(this.el).toggle();
    this.comment_form.form.toggle();
  };

  /* Calls to convert to task API
   *
   * @param {Event} evt
   * @returns false;
   */
  ConvertToTask.convertToTask = function (evt) {
    var self = this;

    evt.preventDefault();
    this.model.convertToTask(
      this.el.serialize(true)
    , function onSuccess(transport) {
        var data = _.parseFromAPI(transport.responseJSON);
        switch(self.model.klassName()) {
          case 'Thread':
            Teambox.collections.threads.remove(self.model);
            var task = new Teambox.Models.Thread(data);
            Teambox.collections.threads.add(task);

            setTimeout(function() {
              var el = jQuery('#activities .thread[data-class=' + task.type() + '][data-id=' + task.id + ']');
              if (el.length) { 
                Effect.ScrollTo(el, { duration: '0.4'});
              }
            }, 500);

            break;
          case 'Conversation':
            Teambox.collections.conversations.remove(this.model);
            var task = new Teambox.Models.Task(data);
            Teambox.collections.tasks.add(task);

            window.location.hash = '#!' + task.publicUrl();
            break;
        }
      }
    , function onError(transport) {
        var message = transport.responseJSON;
        message.errors.each(function (error) {
          self.$('#conversation_name').after("<p class='error'>" + error.message + "</p>");
        })
      }
    );
  };

  // exports
  Teambox.Views.ConvertToTask = Backbone.View.extend(ConvertToTask);

}());
