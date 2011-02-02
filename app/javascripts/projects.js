Project = {
  valid_url: function(){
    var title = $F('project_permalink');
    var class_name = '';
    if(title.match(/^[a-z0-9_\-\.]{5,}$/))
      class_name = 'good'
    else
      class_name = 'bad'

    $('handle').className = class_name;
    Element.update('handle',title)
  }
}

document.on('click', 'a.show_archived', function(e,el) {
  e.stop()
  el.hide()
  el.up().next('.archived_projects').blindDown({duration: 0.2})
})
