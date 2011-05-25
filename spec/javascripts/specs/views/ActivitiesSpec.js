/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("views/activities", function () {

  var ActivitiesView = Teambox.Views.Activities
    , Collection = {}
    , activities;

  beforeEach(function () {
    activities = new ActivitiesView({collection: Collection});
  });

  it('`appendThread` should append a thread into the activities', function () {
    var Construct = Backbone.Model.extend({})
      , thread = new Construct({ type: 'Conversation'
                               , target_type: 'project'
                               , project: 'create'
                               , url: 'http://www.google.com'
                               , project_id: 1
                               });

    activities.appendThread(thread);
    expect(activities.el).toContain('.comment');
  });

  it('`appendThread` should be triggered when an element added to the collection', function () {
    var Construct = Backbone.Model.extend({})
      , thread = new Construct({ type: 'Conversation'
                               , target_type: 'project'
                               , project: 'create'
                               , url: 'http://www.google.com'
                               , project_id: 1
                               });

    activities.trigger('add', thread);
    expect(activities.el).toContain('.comment');
  });

});
