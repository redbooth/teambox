(function  () {

  var Threads = {
    model: Teambox.Models.Thread
  };

  Threads.parse = function (response) {
    return response.collect(function (o) {
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
    return "/api/2/threads.json";
  };

  Threads.fetchNextPage = function (callback) {
    var models = this.models
      , self = this
      , options = {};

    // TODO: once @micho eliminates jQuery from backbone, this will be different
    // because `data` is a jQuery argument for `$.ajax`
    options.data = 'max_id=' + models[models.length - 1].id;
    options.add = true;
    options.success = callback;

    this.fetch(options);
  };

  Threads.getByIdAndClass = function(id, className) {
    var _id, _class;

    if (id === null) return null;
    if (className === null) return null;

    _id = ( id.id != null ? id.id : id );
    _class = ( id.className != null ? id.className() : className );
    return _.detect(this.models, function(model) { return model.id === _id && model.className() === _class; });
  };

  // exports
  Teambox.Collections.Threads = Teambox.Collections.Base.extend(Threads);

}());
