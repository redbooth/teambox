(function () {

  var Comment = {};

  Comment.url = function () {
    return '/api/1' + this.get('parent_url') + '/comments';
  };

  /* Returns the class name
   *
   * @return {String}
   */
  Comment.className = function () {
    return 'Comment';
  };


  // exports
  Teambox.Models.Comment = Teambox.Models.Base.extend(Comment);

}());
