(function () {

  var Page = {};

  /* Get the public url
   *
   * @return {String}
   */
  Page.publicUrl = function () {
    return '/projects/' + this.get('project_id') + '/pages/' + this.id;
  };

  /* Get the API url
   *
   * @return {String}
   */
  Page.url = function () {
    return '/api/1' + this.publicUrl();
  };

  /* Creates data from slots
   */
  Page.setSlots = function() {
    var self = this;
    this.get('slots').each(function(slot){
      slot.rel_object = new Teambox.Models[slot.rel_object_type](slot.rel_object_data);
    });
  };

  Page.parse = function (response) {
    // Link slot objects from references
    var ret = _.parseFromAPI(response);
    var ref_lookup = {};
    response.references.each(function(ref){
      ref_lookup[ref.type + ref.id] = ref;
    });
    ret.slots.each(function(slot){
      slot.rel_object_data = ref_lookup[slot['rel_object_type'] + slot['rel_object_id']];
    });
    return ret;
  };

  /**
   * Check if the model has been loaded fully
   *
   * @return {Boolean}
   */
  Page.isLoaded = function () {
    // If it doesn't have a project_id, for example, it's not loaded
    return !!this.getAttributes().project_id;
  };

  // exports
  Teambox.Models.Page = Teambox.Models.Base.extend(Page);
}());
