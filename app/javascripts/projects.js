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
    return my_external_organizations.collect(function(org) {
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
  ],
  fastCommentForm: function() {
    if (!$('project_id')) {
      return;
    }
    var projects_in_orgs = {};
    (new Hash(my_projects)).each(function(p) {
      var org_id = p[1].organization_id;
      if (projects_in_orgs[org_id]) {
        projects_in_orgs[org_id].push([p[0], p[1].name]);
      }
      else {
        projects_in_orgs[org_id] = [[p[0], p[1].name]];
      }
    });
    var groups = [];
    my_external_organizations.each(function(o) {
      var group = new Element('optgroup', { label: o.name });
      projects_in_orgs[o.id].sortBy(function(p) {return p[1]}).collect(function(p) {return p[0]}).each(function(p) {
        if (!my_projects[p].archived && (my_projects[p].role > 0)) {
          var project = new Element('option', { value: p }).insert(my_projects[p].name);
          group.insert(project);
        }
      });
      groups.push(group);
      $('project_id').insert(group);
    });

  }
}

document.on('click', 'a.show_archived', function(e,el) {
  e.stop()
  el.hide()
  el.up().next('.archived_projects').appear({duration: 0.2})
})

document.on('click', 'a.delete_project', function(e, el){
	e.preventDefault()
	Prototype.Facebox.open($('delete_project_html').innerHTML, 'html delete_project_box', {
		buttons: [
			{className: 'close', href:'#close', description: I18n.translations.common.cancel},
			{className: 'confirm', href:el.readAttribute('href'), description: I18n.translations.projects.fields.delete_this_project,
			 extra:"data-method='delete'"}
		]
	})
})

// Make new project suggestion boxes clickable
document.on('click', '#new_project_suggestions .box', function(e,el) {
  e.stop();
  var link = el.down('a');
  document.location = link.readAttribute('href');
});

document.on("dom:loaded", function () {
  Projects.fastCommentForm();
})

