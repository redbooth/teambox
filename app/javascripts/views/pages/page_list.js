(function () {

  var PageList = { tagName: 'div'
               , className: 'pages'
               , template: Teambox.modules.ViewCompiler('pages.index')
               };

  PageList.events = {};

  PageList.initialize = function (options) {
    _.bindAll(this, "render");
    this.collection.bind('add', this.addPage);
    this.collection.bind('remove', this.removePage);
    this.collection.bind('refresh', this.reload);
    this.title = 'Pages on project';
    this.project_id = options.project_id;
    this.page = options.page;
  };

  PageList.addPage = function(page, collection) {
    this.pageList.insert({top: new Teambox.Views.Page({model:page, root_view: this}).render().el});
  };

  PageList.removePage = function(page, collection) {
    this.pageList.find('.page[data-class=page, data-id='+page.id+']').remove();
  };

  PageList.setActive = function(model) {
    this.current_page = model;
    this.trigger('change_selection', model);
  };

  PageList.reload = function(collection) {
    var self = this;
    this.collection.each(function(model){
      var view = new Teambox.Views.PageListItem({model:model, root_view: self});
      self.page_list.insert({bottom: view.render().el});
    });
  };

  PageList.render = function () {
    var Views = Teambox.Views, self = this;
    this.el.update(this.template({project_id: this.project_id}));
    this.page_list = this.el.down('.page_list');
    this.page_view = this.el.down('.page_view');
    this.reload(this.collection);
    if (this.page) {
      var view;
      if (this.page.id == null) {
        view = new Teambox.Views.PageNew({model: this.page});
      } else {
        view = new Teambox.Views.Page({model: this.page});
      }	
      this.page_view.update(view.render().el);
    }
    return this;
  };

  // exports
  Teambox.Views.PageList = Backbone.View.extend(PageList);
}());
