/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("views/thread", function () {

  var thread_model
    , thread_view
    , thread = { body_html: "<p>qwer</p>\n"
               , created_at: "2011-05-30 17:14:55 +0000"
               , body: "qwer"
               , target_id: 6
               , project_id: 1
               , updated_at: "2011-05-30 17:14:55 +0000"
               , id: 48
               , user_id: 1
               , type: "Comment"
               , hours: null
               , target_type: "Conversation"
               , project: { id: 1
                          , permalink: 'http://zpeaker.com'
                          , name: 'zpeaker'
                          }
      }
    , user = { avatar_url: "http://www.gravatar.com/avatar/49958537f28bbde1a14027f1a5cd06d8?size=48&default=identicon"
             , email: "example_corrina@teambox.com"
             , first_name: "Corrina"
             , id: 2
             , last_name: "Kottke"
             , micro_avatar_url: "http://www.gravatar.com/avatar/49958537f28bbde1a14027f1a5cd06d8?size=24&default=identicon"
             , url: "/user/1"
             , type: "User"
             , username: "corrina"
             };

  beforeEach(function () {
    setFixtures('<div class="thread"><div class="comments">'
              + '<div class="comment comment_header">'
              + '<span class="excerpt"></span>'
              + '</div>'
              + '<div class="more_comments">'
              + '<a href="/activities/1/show_thread?thread_type=conversation">Show previous comments</a>'
              + '</div>'
              + '</div></div>');

    thread_model = new Teambox.Models.Thread({ id: 1
                                             , type: 'Conversation'
                                             , target_type: 'project'
                                             , project: 'create'
                                             , project_id: 1
                                             });

    thread_view = new Teambox.Views.Thread({el: $$('.thread')[0], model: thread_model});
  })

  it('`addComment` should append a comment to the thread', function () {
    thread_view.addComment(thread, {attributes: user});

    expect(thread_view.el).toContain('.comment');
    expect(thread_view.el).toContain('a.micro_avatar');
    expect(thread_view.el.down('.comment_header .excerpt')).toHaveHtml('<strong>Corrina Kottke</strong> qwer');
  });

  it('`reloadComments` should reload the thread comments', function () {
    var evt = {
        stop: function () {},
        element: function () {
          return $$('.more_comments')[0];
        }
      }
      , comment_collection = {fetch: function () {}}
      , comments = {models: [{attributes: thread}, {attributes: thread}, {attributes: thread}]}
      , $stop = sinon.stub(evt, 'stop')
      , $comments = sinon.stub(Teambox.Collections, 'Comments').returns(comment_collection)
      , $fetch = sinon.stub(comment_collection, 'fetch', function (opts) {
          opts.success(comments);
        });

    thread_view.reloadComments(evt);

    expect($stop).toHaveBeenCalledOnce();
    expect($comments).toHaveBeenCalledOnce();
    expect($fetch).toHaveBeenCalledOnce();

    expect(thread_view.el).toContain('.comment');
    expect(thread_view.el.select('.comment').length).toEqual(3);

    [$stop, $comments, $fetch].invoke('restore');
  });

  it('`deleteComment` should delete a comment if the user confirms', function () {
    thread_view.addComment(thread, {attributes: user});

    var evt = {
        stop: function () {},
        element: function () {
          return $$('.comment a.delete')[0];
        }
      }
      , comment_model = {destroy: function () {}}
      , $comment_model = sinon.stub(Teambox.Models, 'Comment').returns(comment_model)
      , $stop = sinon.stub(evt, 'stop')
      , $destroy = sinon.stub(comment_model, 'destroy', function (opts) {
          opts.success();
        })
      , $confirm = sinon.stub(window, 'confirm').returns(true);

    thread_view.deleteComment(evt);

    expect($comment_model).toHaveBeenCalledWith({id: '48', parent_url: '/api/1/projects/1/conversations/1'});
    expect($stop).toHaveBeenCalledOnce();
    expect($confirm).toHaveBeenCalledOnce();
    expect($destroy).toHaveBeenCalledOnce();
    expect(evt.element().up('.comment')).toBeHidden();

    [$comment_model, $stop, $destroy, $confirm].invoke('restore');
  });

  it('`setTargetBlank` should change targets on hovering links', function () {
    var link = new Element('a')
      , evt = {
        element: function () {
          return link;
        }
      };

    thread_view.setTargetBlank(evt);
    expect(link).toHaveAttr('target', '_blank');
  });

  it('`render` should update the thread element and return the view', function () {
    var conversation_model = {}
      , convert_to_task_view = { render: function () {
            return {el: new Element('form', {'class': 'convert_to_task'})};
          }
        }
      , comment_form = { render: function () {
            return {el: new Element('form', {'class': 'comment_form'})};
          }
      }

      , $conversation_model = sinon.stub(Teambox.Models, 'Conversation').returns(conversation_model)
      , $convert_to_task_view = sinon.stub(Teambox.Views, 'ConvertToTask').returns(convert_to_task_view)
      , $comment_form = sinon.stub(Teambox.Views, 'CommentForm').returns(comment_form);

    expect(thread_view.render()).toEqual(thread_view);

    expect(thread_view.el).toHaveAttr('data-class', 'conversation');
    expect(thread_view.el).toHaveAttr('data-id', '1');
    expect(thread_view.el).toHaveAttr('data-project-id', '1');
    expect(thread_view.el).toContain('.comment_header');
    expect(thread_view.el).toContain('form.comment_form');
    expect(thread_view.el).toContain('form.convert_to_task');

    expect($conversation_model).toHaveBeenCalledWith(thread_view.model.attributes);
    expect($convert_to_task_view).toHaveBeenCalledWith({model: conversation_model});
    expect($comment_form).toHaveBeenCalledWith({model: thread_view.model, convert_to_task: convert_to_task_view});

    [$conversation_model, $convert_to_task_view, $comment_form].invoke('restore');
  });
});
