(function () {
  var PageSlot = { 	tagName: 'div'
                     , className: 'page_slot'
                     , Note_template: Teambox.modules.ViewCompiler('notes.show')
                     , Divider_template: Teambox.modules.ViewCompiler('dividers.show')
                     , Upload_template: Teambox.modules.ViewCompiler('uploads.show_page')
                     };

  PageSlot.initialize = function (options) {
    var self = this;
    _.bindAll(this, 'render');
    this.page = options.page;
    this.slot = options.slot;
    this.model.bind('change', this.render);
  };
  
  PageSlot.render = function () {
    var html = this[this.slot.rel_object_type + '_template']({model: this.model});
    this.el.update(html);
    return this;
  };

  // exports
  Teambox.Views.PageSlot = Backbone.View.extend(PageSlot);
}());
