(function () {

  Teambox.Models.Thread = Teambox.Models.Base.extend({

   /* Returns the class name
    *
    * @return {String}
    */
    className: function () {
      return this.get('type');
    }

  , isTask: function () {
      return this.get('type') === 'Task';
    }

  , isConversation: function () {
      return this.get('type') === 'Conversation';
    }

  , url: function () {
      switch (this.get('type')) {
      case 'Conversation':
        return "/projects/" + this.get('project_id') + "/conversations/" + this.id;
      case 'Task':
        return "/projects/" + this.get('project_id') + "/tasks/" + this.id;
      }
    }
  });

}());

