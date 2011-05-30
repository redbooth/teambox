(function () {

  var Comment = {};

  Comment.url = function () {
    return '/api/1' + this.get('parent_url') + '/comments';
  };

  // exports
  Teambox.Models.Comment = Teambox.Models.Base.extend(Comment);

}());
