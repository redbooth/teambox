(function () {

  var Note = {};

  /* Get the public url
   *
   * @return {String}
   */
  Note.publicUrl = function () {
    return '/projects/' + this.get('project_id') + '/pages/' + this.get('page_id') + '/notes/' + this.id;
  };



  // exports
  Teambox.Models.Note = Teambox.Models.Base.extend(Note);
}());
