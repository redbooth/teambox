// Remove a pending invitation
document.on('ajax:create', 'a.invitation-destroy', function(e,link) {
  link.up('.invitation').fade();
})

UserSearchForm = {
  email_regex: new RegExp(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i),
  displaySearchResults: function(el, users) {
    this.users = users;
    var html = Mustache.to_html(
      Templates.invitations.results, {
      users: users });
    el.up('.invite_users').down('.results').update(html);
  },
  getUserData: function(id) {
    return this.users.detect(function(u) { return u.id == id });
  },
  displayInviteForExistingUser: function(el, user) {
    var html = Mustache.to_html(
      Templates.invitations.invite_existing_user,
      user
    );
    el.up('.invite_users').down('.results').update(html);
  },
  noResults: function(el) {
    var terms = el.up('.invite_users').down('input#q').value;
    var email = (terms.match(this.email_regex) || [])[0];
    var html;
    if ((email || "").length > 0) {
      html = Mustache.to_html(
        Templates.invitations.invite_new_user,
        { email: email });
    } else {
      html = "<p>No results found. <b>Type in your contact's email</b> to send an invitation to your project.</p>";
    }
    el.up('.invite_users').down('.results').update(html);
  },
  processUserData: function(users) {
    users.each(function(user){
      user.belongs_to_project = user.projects.any(function(p){ return p.id == current_project });
    });
    console.log(users)
    return users;
  }
};

// Display spinner when searching
document.on('ajax:create', '.invite_users form', function(e,el) {
  el.up('.invite_users').down('.results').update(
    "<p><img src='/images/loading.gif'/> Loading...</p>");
});

// Search form: get results and display them
document.on('ajax:success', '.invite_users form', function(e, el) {
  var users = UserSearchForm.processUserData(e.memo.responseJSON);
  if(users.length === 0) {
    UserSearchForm.noResults(el);
  } else if (users.length === 1 && !users[0].belongs_to_project) {
    UserSearchForm.displayInviteForExistingUser(el, users[0]);
  } else {
    UserSearchForm.displaySearchResults(el, users);
  }
});

// Select a user when there's more than one in the results list
var selectInviteUserFunc = function(e,el) {
  var user = UserSearchForm.getUserData(el.up('.user').readAttribute('data-user-id'));
  UserSearchForm.displayInviteForExistingUser(el, user);
};
document.on('click', '.invite_users .results .user a.button', selectInviteUserFunc);
document.on('click', '.invite_users .results .user a.invite_user', selectInviteUserFunc);

// Failed search
document.on('ajax:failure', '.invite_users form', function(e, el) {
  alert("There was an error and we couldn't find that user. If the problem persists, please contact support");
});

// Select language
document.on('click','#invitation_select_language', function(e) {
  e.stop();
  e.element().replace($("all_locales").innerHTML);
  $('all_locales').remove();
})

