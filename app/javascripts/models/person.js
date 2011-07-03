Teambox.Models.Person = Teambox.Models.Base.extend({

   /* Returns the class name
    *
    * @return {String} class_name
    */
    className: function () {
      return 'User';
    }

  , url: function() {
      return "/api/1/projects/" + this.get('project_id') +  "/people/" + this.id;
    }

  , publicUrl: function() {
      return "/users/" + this.get('user').username;
    }


});

