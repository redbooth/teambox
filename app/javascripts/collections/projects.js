(function () {
  var ProjectsCollection = { model: Teambox.Models.Project };

  ProjectsCollection.parse = function (response) {
    return _.parseFromAPI(response);
  };

  ProjectsCollection.url = function () {
    return '/api/1/projects';
  };

  // Returns organizations, adding the following arrays:
  // projects, active_projects, archived_projects
  // Also adds the role property, for the visualization
  ProjectsCollection.organizations = function () {
    var self = this
      , orgs = this.models.collect(function (p) {
          return p.get('organization');
        }).uniq()
      , projects = this.models.collect(function (p) {
          return p.getAttributes();
        }).collect(function (p) {
          // FIXME: This should load the proper roles for each project
          // They are not being sent in the API request currently
          p.role = 3; // for now I'm setting it to admin
          p.my_role = self.roles[p.role];
          p.admin = p.role === 3;
          return p;
        });

    orgs.each(function (org) {
      org.projects = projects
        .select(function (p) {
          return p.organization_id === org.id;
        })
        .sortBy(function (p) {
          return p.name.toLowerCase();
        });

      org.active_projects = org.projects
        .reject(function (p) {
          return p.archived;
        });

      org.archived_projects = org.projects
        .select(function (p) {
          return p.archived;
      });

      org.has_archived_projects = (org.archived_projects.length > 0)
        ?  { count: org.archived_projects.length
           , name: org.name
           , projects: org.archived_projects }
        : false;

      return org;
    });

    return orgs;
  };

  ProjectsCollection.roles = [
    I18n.translations.roles.observer
  , I18n.translations.roles.commenter
  , I18n.translations.roles.participant
  , I18n.translations.roles.admin
  ];

  // exports
  Teambox.Collections.Projects = Teambox.Collections.Base.extend(ProjectsCollection);

}());
