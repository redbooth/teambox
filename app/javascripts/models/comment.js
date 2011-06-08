(function () {

  var Comment = {};

  Comment.url = function () {
    var base = this.get('parent_url') + '/comments/';

    return this.isNew() ? base : base + this.id;
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
