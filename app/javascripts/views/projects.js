Teambox.Views.Projects = Backbone.View.extend({

  initialize: function(options) {
    this.app = options.app;

    _.bindAll(this, 'render');
    // TODO: Listen for changes in my projects
  },

  template: Handlebars.compile(Templates.projects.index),

  render: function() {
    $('content').update( this.template({
      organizations: this.collection.organizations()
    }));
  },

  events: {
    "click a.show_achived": "showArchived"
  },

  // Reveal archived projects under one organization
  showArchived: function(evt) {
    evt.currentTarget.hide();
    evt.currentTarget.up()
      .next('.archived_projects')
      .appear({duration: 0.2});
    return false;
  }

});

