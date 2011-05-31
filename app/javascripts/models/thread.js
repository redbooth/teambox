(function () {

  Teambox.Models.Thread = Teambox.Models.Base.extend({
    initialize: function () {
    }

  , render: function () {
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

