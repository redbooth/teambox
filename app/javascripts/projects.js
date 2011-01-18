Projects = {
  organizationsWithProjects: function() {
    var projects = [];
    for(var i in my_projects) {
      if(!isNaN(i) && my_projects[i]) {
        var p = my_projects[i];
        p.id = parseInt(i);
        p.my_role = Projects.roles[p.role];
        p.admin = p.role == 3;
        projects.push(p);
      }
    }
    return my_organizations.collect(function(org) {
      org.projects = projects.
        select(function(p) {
          return p.organization_id == org.id; }).
        sortBy(function(p) {
          return p.name.toLowerCase(); });
      org.active_projects = org.projects.
        reject(function(p) {
          return p.archived; });
      org.archived_projects = org.projects.
        select(function(p) {
          return p.archived; });
      org.has_archived_projects =
        (org.archived_projects.length > 0) ?
        { count: org.archived_projects.length,
          name: org.name,
          projects: org.archived_projects } :
        false;
      return org;
    }).compact();
  },
  showAllProjects: function() {
    var html = Mustache.to_html(Templates.projects.index, {
      organizations: Projects.organizationsWithProjects()
    });
    Pane.replace(html);
  },
  roles: [
    I18n.translations.roles.observer,
    I18n.translations.roles.commenter,
    I18n.translations.roles.participant,
    I18n.translations.roles.admin
  ]
}

document.on('click', 'a.show_archived', function(e,el) {
  e.stop()
  el.hide()
  el.up().next('.archived_projects').appear({duration: 0.2})
})
