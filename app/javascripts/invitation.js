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
    var invite_url = '/api/1/projects/' + current_project + '/invitations';
    var html = Mustache.to_html(
      Templates.invitations.invite_existing_user,
      $H(user).merge({
        'invite_url': invite_url, 
        'organization': this.current_organization().name
      }).toObject());
    el.up('.invite_users').down('.results').update(html);
  },
  displayInvitation: function(el, invitation) {
    var invite_url = '/api/1/projects/' + current_project + '/invitations';
    var html = Mustache.to_html(
      Templates.invitations.invitation,
      $H(invitation).merge({'invite_url': invite_url}).toObject()
    );
    el.update(html);
  },
  noResults: function(el) {
    var terms = el.up('.invite_users').down('input#q').value;
    var invite_url = '/api/1/projects/' + current_project + '/invitations';
    var email = (terms.match(this.email_regex) || [])[0];
    var html;
    if ((email || "").length > 0) {
      html = Mustache.to_html(
        Templates.invitations.invite_new_user, { 
          email: email, 
          invite_url: invite_url, 
          organization: this.current_organization().name 
        });
    } else {
      html = "<p>No results found. <b>Type in your contact's email</b> to send an invitation to your project.</p>";
    }
    el.up('.invite_users').down('.results').update(html);
  },
  processUserData: function(users) {
    users.each(function(user){
      user.belongs_to_project = user.projects.any(function(p){ return p.id == current_project });
    });
    return users;
  },
  loading: function(){
    return "<p class='loading'><img src='/images/loading.gif'/> Loading...</p>";
  },
  current_organization: function(){
    return my_organizations.detect(function(o) { 
      return o.id == my_projects[current_project].organization_id 
    });
  }
};

// Display spinner when searching
document.on('ajax:create', 'form.user_finder', function(e,el) {
  el.up('.invite_users').down('.results').update(UserSearchForm.loading());
});

// Search form: get results and display them
document.on('ajax:success', 'form.user_finder', function(e, el) {
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
document.on('ajax:failure', 'form.user_finder', function(e, el) {
  alert("There was an error and we couldn't find that user. If the problem persists, please contact support");
});

// Submit invite form
// Search form: get results and display them

document.on('ajax:before', 'form.send_invite', function(e, el) {
  var inner = el.down('.inner');
  inner.hide();
  inner.insert({before: UserSearchForm.loading()});
});

document.on('ajax:success', 'form.send_invite', function(e, el) {
  UserSearchForm.displayInvitation(el, JSON.parse(e.memo.responseText).objects[0]);
});


// Search form: get results and display them
document.on('ajax:failure', 'form.send_invite', function(e, el) {
  el.down('.loading').remove();
  el.down('.inner').show();
  el.down('.inner').down('input').insert({before:'<p class=\'error\'>User could not be invited!</p>'});
});


// Select language
document.on('click','#invitation_select_language', function(e) {
  e.stop();
  e.element().replace($("all_locales").innerHTML);
  $('all_locales').remove();
})

