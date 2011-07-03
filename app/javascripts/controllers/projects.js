(function () {

  var ProjectsController = { routes: { '/projects'                     : 'projects_index'
                                     , '/projects/new'                 : 'projects_new'
                                     , '/projects/:id'                 : 'projects_show'
                                     , '/projects/:project/people'     : 'people_index'
                                     , '/projects/:project/settings'   : 'project_edit'
                                     , '/projects/:project/task_lists' : 'task_lists'
                                     }
                           }
    , Views = Teambox.Views
    , collections = Teambox.collections;

  ProjectsController.projects_index = function () {
    Views.Sidebar.highlightSidebar('projects_link');
    $('content').update((new Views.Projects({collection: collections.projects})).render().el);
  };

  ProjectsController.projects_new = function () {
    Teambox.Views.Sidebar.highlightSidebar('new_project_link');
    $('content').update('new project');
  };

  ProjectsController.projects_show = function (permalink) {
    var project = collections.projects.getByPermalink(permalink)
      , threads = Teambox.helpers.projects.filterActivitiesByProject(project.id, Teambox.collections.threads)
      , show_more = '<a href="#" class="button" id="activity_paginate_link"><span>Show more</span></a>';

    Views.Sidebar.highlightSidebar('project_' + permalink + '_activities');
    $('view_title').update(project.get('name') + ' - Recent activity');
    $('content').update((new Teambox.Views.Activities({collection: threads})).render().el);
    $('content').insert({bottom: show_more});

    // TODO: move this inside the view
    $('activity_paginate_link').observe('click', function onShowMore(event) {
      var el = event.element();
      Element.replace('activity_paginate_link', '<img id="activity_paginate_link" src="/images/loading.gif" alt="loading..." />');

      threads.fetchNextPage(function (collection, response) {
        Element.replace('activity_paginate_link', show_more);
        $('activity_paginate_link').observe('click', onShowMore);
        if (response.objects.length <= 50) {
          el.hide();
        }
      });
    });
  };

  ProjectsController.task_lists = function (permalink) {
    var tasks = collections.tasks.filteredByProject(permalink)
      , collection = (new Teambox.Collections.Tasks(tasks))
      , project = collections.projects.getByPermalink(permalink)
      , view = new Views.TaskLists({collection: collection, project: project});

    Teambox.Views.Sidebar.highlightSidebar('project_' + project + '_task_lists');

    $('content')
      .update(view.render().el);

    view.makeAllSortable();

    $('view_title').update(view.title);
  };

  // exports
  Teambox.Controllers.ProjectsController = Teambox.Controllers.BaseController.extend(ProjectsController);

}());
