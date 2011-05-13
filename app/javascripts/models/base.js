Teambox.Models.Base = Backbone.Model.extend({
  toJSON: function() {
    return _.reduce(this.attributes, function(attrs, v, k) {
     if (_.all(['object', 'function'], function(type) {return typeof v != type})) {
       attrs[k]= v;
     }
     return attrs;
    }, {});
  }
});
