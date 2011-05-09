Teambox.Models.Conversation = Backbone.Model.extend({

  initialize: function() {
  },

  url: function() {
    return "/api/1/conversations/" + this.get('id');
  },

  parse: function(response) {
    return _.parseFromAPI(response)[0];
  },

  // Check if the model has been loaded fully
  isLoaded: function() {
    // If it doesn't have a project_id, for example, it's not loaded
    return !!this.toJSON().project_id;
  }

});
