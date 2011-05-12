Teambox.Controllers.PagesController = Backbone.Controller.extend({
  routes: {
    '/projects/:project/pages'             : 'pages_index',
    '/projects/:project/pages/:id'         : 'pages_show'
  },

  pages_new: function() {
    $('content').update( 'new page' );
  },

  pages_show: function() {
    $('content').update( 'show page' );
  }
});

_.extend(Teambox.Controllers.PagesController.prototype, Teambox.Views.Utility);
