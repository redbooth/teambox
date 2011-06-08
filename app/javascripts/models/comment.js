(function () {

  var Comment = {};

  Comment.url = function () {
    return this.get('parent_url') + '/comments/' + this.id;
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
