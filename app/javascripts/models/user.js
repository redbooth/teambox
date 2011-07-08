Teambox.Models.User = Teambox.Models.Base.extend({

    // Listen for changes in the username field
    initialize: function () {
      _.bindAll(this, 'render');
      this.bind('change:username', this.render);
    }

   /* Returns the class name
    *
    * @return {String} class_name
    */
  , className: function () {
      return 'User';
    }


  , username_template: Teambox.modules.ViewCompiler(false,
      "a(href='/users/#{self.username}')= self.username"
    )

  , full_name_template: Teambox.modules.ViewCompiler(false, 
      "a(href='/users/#{self.username}')= self.full_name(self)"
    )

    // Updates the username link on the header
  , render: function() {
      $('username').update(
        this.username_template(this.getAttributes())
      );
      return this;
    }

  , url: function() {
      return "/api/1/account";
    }

  /* Get the public url
   *
   * @return {String}
   */
  , publicUrl: function () {
      return '/users/' + this.get('login');
    }
});

