Teambox.Models.Base = Backbone.Model.extend({
  getAttributes: function() {
    return _.clone(this.attributes);
  },
  toJSON: function() {
    return _.reduce(this.attributes, function(attrs, v, k) {
      var checkType = function(type) {
        return (k !== 'comments_attributes') ? typeof v != type : true;
      };

     if (_.all(['object', 'function'], checkType)) { attrs[k]= v; }
     return attrs;
    }, {});
  }
});
