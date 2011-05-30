(function() {
  Teambox.Collections.Tasks = Teambox.Collections.Base.extend({

    model: Teambox.Models.Task,

    // Fetch references from the API response
    parse: function(response) {
      return _.parseFromAPI(response);
    },

    url: function() {
      return "/api/1/tasks";
    },

    // Active tasks assigned to me
    mine: function() {
      return this.filter( function(t) { 
        var assigned = t.get('assigned');
        return assigned && (assigned.user.id == my_user.id);
      });
    },

    // Active tasks assigned to me that are due today or late
    today: function() {
      return this.mine().filter( function(t) {
        var today = new Date();
        var tomorrow = today.setDate(today.getDate()+1);
        var due = t.get('due_on');
        return due && new Date(due) < tomorrow;
      });
    },

    // Active tasks assigned to me that are late
    late: function() {
      return this.mine().filter( function(t) {
        var today = new Date();
        var due = t.get('due_on');
        return due && new Date(due) < today;
      });
    }

  });
})();

