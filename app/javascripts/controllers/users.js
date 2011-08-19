Teambox.Controllers.UsersController = Teambox.Controllers.BaseController.extend({
  routes: {
    '!/users/:id'         : 'users_show'
  },

  users_show: function() {
    $('content_header').update('');
    $('content').update( 'show user' );
  }
});
