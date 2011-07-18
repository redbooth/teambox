(function () {

  var SimpleConversationForm = { tagName: 'div'
                    , className: 'simple_conversation'
                    };

  /* updates thread el using a template
   *
   * @return {Object} self
   */
  SimpleConversationForm.initialize = function (options) {
    _.bindAll(this, "render", "updateFormAttributes");

    this.model = new Teambox.Models.Thread({type: 'Conversation', simple: true, title: 'Untitled', recent_comments: []});
    this.comment_form = new Teambox.Views.CommentForm({
        model: this.model
      , thread: this
      , simple: true
    });
    this.google_docs = new Teambox.Views.GoogleDocs({comment_form: this.comment_form});

    return this;
  };

  SimpleConversationForm.render = function () {
    var projects = Teambox.collections.projects.map(function(p) { return {id: p.id, value: p.get('name')};})
      , model = this.model
      , watchers_update = this.comment_form.watchers.update;

    this.el.update('');
    this.el.insert({bottom: this.comment_form.render().el});
    this.el.insert({bottom: this.google_docs.render().el});

    var dropdown = new Teambox.Views.DropDown({
        el: this.el.down('.dropdown_projects')
      , collection: projects
      , className: 'dropdown_projects'
     });

    function updateProjectInModel(project_id) { 
      model.set({'project_id': project_id}); 
    };

    var dropdown_callbacks = [watchers_update, updateProjectInModel, this.updateFormAttributes];

    _.each(dropdown_callbacks, function(callback) {
      dropdown.bind('change:selection', callback);
    });

    dropdown.render();

    return this;
  };

  SimpleConversationForm.updateFormAttributes = function(project_id) {
    this.comment_form.updateFormAttributes(project_id);
  };

  /* Cleans the form
   */
  SimpleConversationForm.reset = function () {
    this.el.select('.google_docs_attachment_form_area .fields input').invoke('remove');
    this.el.select('.google_docs_attachment_form_area .file_list li').invoke('remove');
  };

  // exports
  Teambox.Views.SimpleConversationForm = Backbone.View.extend(SimpleConversationForm);
}());
