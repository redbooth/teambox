(function  () {

  var Pages = {
    model: Teambox.Models.Page
  };

  Pages.parse = function (response) {
    // Link slot objects from references
    var ret = _.parseFromAPI(response);
    var ref_lookup = {};
    response.references.each(function(ref){
      ref_lookup[ref.type + ref.id] = ref;
    });
    ret.each(function(page){
      page.slots.each(function(slot){
        slot.rel_object_data = ref_lookup[slot['rel_object_type'] + slot['rel_object_id']];
      });
    });
    return ret;
  };

  Pages.url = function () {
    return "/api/1/projects/" + this.options.project_id + "/pages.json";
  };

  // exports
  Teambox.Collections.Pages = Teambox.Collections.Base.extend(Pages);

}());
