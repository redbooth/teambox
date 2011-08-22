(function () {
  var PageListItem = { 	tagName: 'div'
                     , className: 'page'
                     , template: Teambox.modules.ViewCompiler('pages.show_list')
                     , loading: Teambox.modules.ViewCompiler('partials.loading')
                     };

  PageListItem.events = {
    'click': 'setPage'
  };

  PageListItem.initialize = function (options) {
    var self = this;
    _.bindAll(this, 'render');
    this.root_view = options.root_view;
    this.root_view.bind('change_selection', function(conversation){
      if (self.model.id == conversation.id)
        jQuery(self.el).addClass('active');
      else
        jQuery(self.el).removeClass('active');
    });
    this.model.bind('change', this.render);
  };
  
  PageListItem.setPage = function() {
    this.root_view.setActive(this.model);
    document.location.hash = '!/projects/' + this.root_view.project_id + '/pages/' + this.model.id;
  };
  
  PageListItem.render = function () {
    if(this.model.isLoaded()) {
      var html = this.template({model: this.model});
      jQuery(this.el).html(html);
    } else {
      jQuery(this.el).html(loading());
    }
    return this;
  };

  // exports
  Teambox.Views.PageListItem = Backbone.View.extend(PageListItem);
}());
