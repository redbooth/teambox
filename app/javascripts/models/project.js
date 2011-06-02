Teambox.Models.Project = Teambox.Models.Base.extend({
   /* Returns the class name
    *
    * @return {String}
    */
    className: function () {
      return 'Project';
    }

  , url: function() {
      return "/api/1/projects/" + this.get('id');
    }
});

