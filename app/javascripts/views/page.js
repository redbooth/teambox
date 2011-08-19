(function () {
  var Page = { className: 'page'
             , template: Teambox.modules.ViewCompiler('pages.show')
             , loading: Teambox.modules.ViewCompiler('partials.loading')
             };

  Page.initialize = function (options) {
    _.bindAll(this, 'render');
    this.model.bind('change', this.render);
    this.title = this.name;
  },


  /* TODO: Handle 404s or permission denied for conversations
   * TODO: Shouldn't render to the DOM!
   */
  Page.render = function () {
    if(this.model.isLoaded()) {
      var html = this.template({ model: this.model });
      jQuery(this.el).html(html);

      var self = this;
      var slots = this.$('.slots');

      // Load slots...
      this.model.get('slots').each(function(slot){
        var slot_view = new Teambox.Views.PageSlot({
          page:self, model:slot.rel_object, slot:slot });
        slots.append(slot_view.render().el);
      });
    } else {
      $(this.el).html(this.loading());
    }
    return this;
  }

  // exports
  Teambox.Views.Page = Backbone.View.extend(Page);
}());
