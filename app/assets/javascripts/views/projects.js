(function () {
  var ProjectView = { className: 'projects'
                    , template: Teambox.modules.ViewCompiler('projects.index')
                    };

  ProjectView.events = {
    'click a.show_achived': 'showArchived'
  };

  ProjectView.initialize = function (options) {
    this.collection = options.collection;
    _.bindAll(this, 'render');
    // TODO: Listen for changes in my projects
  };


  ProjectView.render = function () {
    this.el.update(this.template({organizations: this.collection.organizations()}));

    return this;
  };

  // Reveal archived projects under one organization
  ProjectView.showArchived = function (evt) {
    evt.currentTarget.hide();
    evt.currentTarget.up()
      .next('.archived_projects')
      .appear({duration: 0.2});
    return false;
  };

  // exports
  Teambox.Views.Projects = Backbone.View.extend(ProjectView);
}());
