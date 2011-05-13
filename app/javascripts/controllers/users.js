Teambox.Controllers.UsersController = Teambox.Controllers.BaseController.extend({
  routes: {
    '/users/:id'         : 'users_show'
  },

  users_show: function() {
    $('content').update( 'show user' );
  }
});
