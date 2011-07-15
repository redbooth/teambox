(function () {
  var PagesController = { routes: {  '/projects/:project/pages'             : 'index'
                                  ,  '/projects/:project/pages/new'         : 'new'
                                  ,  '/projects/:project/pages/:id'         : 'show'}};

  PagesController['new'] = function(project_id) {
    var collection = Teambox.collections.conversations;
    var page = new Teambox.Models.Page();
    var view = new Teambox.Views.PageList({collection: collection, page: page, project_id: project});
    $('content').update(view.render().el);
  };

  PagesController.show = function(project_id, id) {
    var model = Teambox.collections.pages.get(id);

    if (!model) {
      model = new Teambox.Models.Page({ id: id });
      model.fetch({success: function(){model.setSlots();}});
    } else {
      model.setSlots();
    }

    var collection = Teambox.collections.pages;
    var view = new Teambox.Views.PageList({collection: collection, page: model, project_id: project_id});
    $('content').update(view.render().el);

    view.setActive(model);

    Teambox.Views.Sidebar.highlightSidebar('project_' + project_id + '_pages');
    $('view_title').update(view.title);
  };

  PagesController.index = function(project_id) {
    var collection = Teambox.collections.pages;
    var view = new Teambox.Views.PageList({collection: collection, project_id: project_id});
    $('content').update(view.render().el);

    Teambox.Views.Sidebar.highlightSidebar('project_' + project_id + '_pages');
    $('view_title').update(view.title);
  };

  // exports
  Teambox.Controllers.PagesController = Teambox.Controllers.BaseController.extend(PagesController);
}());
