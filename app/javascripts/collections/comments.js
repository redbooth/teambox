(function  () {

  var Comments = {
    model: Teambox.Models.Comment
  };

  Comments.initialize = function (models, options) {
    this.project_id = options.project_id;
    this.task_id = options.task_id;
    this.conversation_id = options.conversation_id;
  };

  Comments.parse = function (response) {
    return _.parseFromAPI(response);
  };

  Comments.url = function () {
    var url = '/api/1';

    if (this.project_id) {
      url += '/projects/' + this.project_id;
    }

    if (this.task_id) {
      url += '/tasks/' + this.task_id;
    } else if (this.conversation_id) {
      url += '/conversations/' + this.conversation_id;
    }

    url += '/comments';

    return url;
  };

  // exports
  Teambox.Collections.Comments = Teambox.Collections.Base.extend(Comments);

}());
