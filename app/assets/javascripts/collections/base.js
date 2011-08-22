(function() {
  Teambox.Collections.Base = Backbone.Collection.extend({
    getAttributes : function() {
      return this.map(function(model){ return model.getAttributes(); });
    },
    initialize: function(models, options){
      this.options = options;
    }
  });
}());

