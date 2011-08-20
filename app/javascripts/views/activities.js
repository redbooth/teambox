(function () {

  var Activities = { tagName: 'div'
                   , id: 'activities'
                   , templates: { project:  { create: Handlebars.compile(Templates.activities.project_create) }
                                , note:     { create: Handlebars.compile(Templates.activities.note_create)
                                            , edit: Handlebars.compile(Templates.activities.note_edit) }
                                , page:     { create: Handlebars.compile(Templates.activities.page_create)
                                            , edit: Handlebars.compile(Templates.activities.page_edit) }
                                , tasklist: { create: Handlebars.compile(Templates.activities.task_list_create) }
                                , show_more: Teambox.modules.ViewCompiler('partials.show_more')
                                , loading: Teambox.modules.ViewCompiler('partials.loading_img')
                                , raw_activity: Handlebars.compile(
                                    "<div class='activity'>activity_{{id}} {{target_type}} {{action}} {{#target}}{{{body_html}}}{{/target}} </div>"
                                  )
                                }
      };

  Activities.events = {
    'click #activity_paginate_link': 'showMore'
  };

  Activities.initialize = function (options) {
    _.bindAll(this, 'render');

    this.collection.unbind('add');
    this.collection.unbind('remove');
    this.collection.bind('add', Activities.appendActivity.bind(this));
    this.collection.bind('remove', Activities.removeActivity.bind(this));
  };

  Activities.showMore = function showMore(event) {
    var show_more = this.templates.show_more()
    ,  loading = this.templates.loading();

    jQuery('#activity_paginate_link').replaceWith(loading);

    this.collection.fetchNextPage(function (collection, response) {
      jQuery('#activity_paginate_link').replaceWith(show_more);
      // TODO: Hide the button if not enough activities to paginate
    });
  };

  Activities.appendActivity = function appendActivity(thread) {
    var template;
    if (thread.get('type') === "Conversation" || thread.get('type') === "Task") {
      jQuery(this.el).prepend((new Teambox.Views.Thread({controller: this.controller, model: thread})).render().el);
    } else if (thread.get('type') === 'Page') {
      jQuery(this.el).prepend((new Teambox.Views.PageTeaser({model: thread})).render().el);
    } else {
      var template = this.templates[thread.get('target_type').toLowerCase()] || {}
      template = template[thread.get('action')] || this.templates.raw_activity;
      jQuery(this.el).prepend( template(thread.getAttributes()) );
    }
  };

  /* Updates the element with each thread
   *
   * @return self
   */
  Activities.render = function () {
    jQuery(this.el).empty();
    this.collection.models.each(this.appendActivity.bind(this));
    jQuery(this.el).append(this.templates.show_more());

    return this;
  };

  /* Removes the thread from the DOM
   *
   * @return self
   */
  Activities.removeActivity = function (thread) {
    var selector = '.thread[data-class=' + thread.type() + '][data-id=' + thread.id + ']';
    this.$(selector).remove();

    return this;
  };


  // exports
  Teambox.Views.Activities = Backbone.View.extend(Activities);
}());
