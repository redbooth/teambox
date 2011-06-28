/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("views/activities", function () {

  var ActivitiesView = Teambox.Views.Activities
    , Thread = Teambox.Models.Thread
    , Collection = _.extend({}, Backbone.Events)
    , activities;

  beforeEach(function () {
    setFixtures('<div id="view_title"></div><div id="content"><a id="activity_paginate_link">show more</a></div>');
    activities = new ActivitiesView({collection: Collection});
  });

  it('`appendActivity` should append a conversation into the activities', function () {
    var thread = new Thread({type: 'Conversation', url: 'http://www.google.com', project_id: 1})
      , thread_view = {render: function () {
          return {el: 'foo'};
        }}
      , $new_thread = sinon.stub(Teambox.Views, 'Thread', function () {
          return thread_view;
        })
      , $insert = sinon.stub(activities.el, 'insert');

    activities.appendActivity(thread);

    expect($new_thread).toHaveBeenCalledWith({model: thread});
    expect($insert).toHaveBeenCalledWith({bottom: 'foo'});

    $new_thread.restore();
    $insert.restore();
  });

  it('`appendActivity` should append a task into the activities', function () {
    var thread = new Thread({type: 'Task', url: 'http://www.google.com', project_id: 1})
      , thread_view = {render: function () {
          return {el: 'foo'};
        }}
      , $new_thread = sinon.stub(Teambox.Views, 'Thread', function () {
          return thread_view;
        })
      , $insert = sinon.stub(activities.el, 'insert');

    Collection.trigger('add', thread);

    expect($new_thread).toHaveBeenCalledWith({model: thread});
    expect($insert).toHaveBeenCalledWith({bottom: 'foo'});

    $new_thread.restore();
    $insert.restore();
  });

  it('`appendActivity` should also append a non-thread to the activities', function () {
    var thread = new Thread({target_type: 'project', action: 'create', url: 'http://www.google.com', project_id: 1})
      , $template = sinon.stub(activities.templates.project, 'create', function (attr) {
          return 'foo';
        })
      , $insert = sinon.stub(activities.el, 'insert');

    activities.appendActivity(thread);

    expect($template).toHaveBeenCalledWith(thread.getAttributes());
    expect($insert).toHaveBeenCalledWith({bottom: 'foo'});

    $template.restore();
    $insert.restore();
  });

  it('`render` should add all the threads into the activities div and update `content` with it', function () {
    var $appendActivity = sinon.stub(activities, 'appendActivity', function (thread) {
      activities.el.insert({bottom: new Element('div', {'class': thread.get('type')})});
    });

    activities.collection = [
      new Thread({type: 'Conversation', url: 'http://www.google.com', project_id: 1})
    , new Thread({type: 'Task', url: 'http://www.google.com', project_id: 1})
    ];

    activities.collection.fetchNextPage = function () {};

    activities.render();

    expect($appendActivity).toHaveBeenCalledTwice();
    expect($('view_title')).toHaveText('Recent activity');
    expect($('content')).toContain('a.button');
    expect($('content')).toContain('div.Conversation');
    expect($('content')).toContain('div.Task');
  });
});
