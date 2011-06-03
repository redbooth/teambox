// update edited comment
document.on('ajax:success', '#facebox form.edit_comment', function(e, form) {
  var commentID = form.readAttribute('action').match(/\d+/g).last()
  $('comment_' + commentID).replace(e.memo.responseText)
  Prototype.Facebox.close()
  $('comment_' + commentID).highlight()
})

// remove deleted comment
document.on('ajax:success', '.comment:not(div[data-class=conversation].thread .comment) .actions_menu a[data-method=delete]', function(e, link) {
  e.findElement('.comment').remove()
})

// when deleting comment, remove the conversation if empty: no comments, no title.
document.on('ajax:success', 'div[data-class=conversation].thread .comment .actions_menu a[data-method=delete]', function(e, link) {
  var conversation = e.findElement('.thread')
  if (conversation.select('.comment').length == 1 && conversation.select('.title').length == 0) conversation.remove()
  else e.findElement('.comment').remove()
})

// TODO: to test!
document.on('focusin', 'form#new_invitation input#invitation_user_or_email', function(e, input) {
  var form = e.findElement('form')
    , people = _.unique(_.flatten(_.map(Teambox.collections.projects, function (project) {
        return project.getAutocompleterUserNames().reject(function(e) {
          return e.match('@all');
        });
      })))
    , autocompleter = input.retrieve('autocompleter');

  if (autocompleter) {
    // update options array in case the projects selector changed value
    autocompleter.options.array = people
  } else {
    var container = new Element('div', { 'class': 'autocomplete' }).hide()
    input.insert({ after: container })
    autocompleter = new Autocompleter.Local(input, container, people, { tokens:[' '] })
    input.store('autocompleter', autocompleter)
  }
})
