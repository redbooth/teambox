Teambox.Models.Project = Teambox.Models.Base.extend({
   /* Returns the class name
    *
    * @return {String}
    */
    className: function () {
      return this.get('type');
    }

  , url: function() {
      return "/api/1/projects/" + this.get('id');
    }
});

