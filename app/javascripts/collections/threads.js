(function  () {

  var Threads = {
    model: Teambox.Models.Thread
  };

  Threads.parse = function (response) {
    return _.parseFromAPI(response).collect(function (o) {
      if (o.target.type === "Comment") {
        return o.target.target;
      } else if (o.target.type === "Task" || o.target.type === "Conversation") {
        return o.target;
      } else {
        return o;
      }
    }).compact().uniq();
  };

  Threads.url = function () {
    return "/api/1/activities";
  };

  Threads.fetchNextPage = function (options) {
    var models = this.models;

    options = options || {};

    // TODO: once @micho eliminates jQuery from backbone, this will be different
    // because `data` is a jQuery argument for `$.ajax`
    options.data = 'max_id=' + models[models.length - 1].id;
    options.add = true;

    this.fetch(options);
  }

  // exports
  Teambox.Collections.Threads = Backbone.Collection.extend(Threads);

}());
