(function () {

  var SimpleConversationForm = { tagName: 'div'
                    , className: 'simple_conversation'
                    };

  /* updates thread el using a template
   *
   * @return {Object} self
   */
  SimpleConversationForm.initialize = function (options) {
    _.bindAll(this, "render");

    this.model = new Teambox.Models.Thread({type: 'Conversation', simple: true, title: 'Untitled'});
    this.comment_form = new Teambox.Views.CommentForm({
        model: this.model
      , thread: this
      , simple: true
    });
    this.google_docs = new Teambox.Views.GoogleDocs({comment_form: this.comment_form});

    return this;
  };

  SimpleConversationForm.render = function () {
    var projects = Teambox.collections.projects.map(function(p) { return {id: p.id, value: p.get('name')};});
    this.el.update('');
    this.el.insert({bottom: this.comment_form.render().el});
    this.el.insert({bottom: this.google_docs.render().el});

    this.projects_dropdown = new Teambox.Views.DropDown({
        el: this.el.down('.dropdown_projects')
      , collection: projects
      , className: 'dropdown_projects'
     }).bind('change:selection', this.comment_form.watchers.update);
     this.projects_dropdown.render();

    return this;
  };

  // exports
  Teambox.Views.SimpleConversationForm = Backbone.View.extend(SimpleConversationForm);
}());
