/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("views/activities", function () {

  var ActivitiesView = Teambox.Views.Activities
    , Collection = _.extend({}, Backbone.Events)
    , activities;

  beforeEach(function () {
    setFixtures('<div id="content"><a id="activity_paginate_link">show more</a></div>');
    activities = new ActivitiesView({collection: Collection});
  });

  it('`appendThread` should append a thread into the activities', function () {
    var thread = new Teambox.Models.Thread({ type: 'Conversation'
                                           , target_type: 'project'
                                           , project: 'create'
                                           , url: 'http://www.google.com'
                                           , project_id: 1
                                           });

    activities.appendThread(thread);
    expect(activities.el).toContain('.comment');
  });

  it('`appendThread` should be triggered when an element added to the collection', function () {
    var thread = new Teambox.Models.Thread({ type: 'Conversation'
                                           , target_type: 'project'
                                           , project: 'create'
                                           , url: 'http://www.google.com'
                                           , project_id: 1
                                           });

    Collection.trigger('add', thread);
    expect(activities.el).toContain('.comment');
  });

  it('`hidePagination` should be triggered when no more elements are added to the collection', function () {
    Collection.trigger('no_more_pages');
    expect($('activity_paginate_link')).toBeHidden();
  });

});
