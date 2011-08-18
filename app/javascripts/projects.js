Projects = {
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

