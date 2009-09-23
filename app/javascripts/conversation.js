Conversation = {
  update_comments: function() {
    var params = {};
    if ($('sort_uploads').checked) {
      params = { show: 'uploads' };
    } else if ($('sort_hours').checked) {
      params = { show: 'hours' };
    }
    new Ajax.Request(conversation_update_url, { method: 'get', parameters: params });
  }
};

Event.addBehavior({
  "#sort_uploads:click": function(e){
    Conversation.update_comments();
  },
  "#sort_all:click": function(e){
    Conversation.update_comments();
  },
  "#sort_hours:click": function(e){
    Conversation.update_comments();
  }
});