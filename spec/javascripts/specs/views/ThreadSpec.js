/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("views/thread", function () {

  var thread_model
    , thread_view
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
    setFixtures('<div class="thread"><div class="comments"></div></div>');
    thread_model = new Teambox.Models.Thread({ type: 'Conversation'
                                             , target_type: 'project'
                                             , project: 'create'
                                             , project_id: 1
                                             });

    thread_view = new Teambox.Views.Thread({el: $$('.thread')[0], model: thread_model});
  })

  it('`addComment` should append a comment to the thread', function () {
    thread_view.addComment({
      body_html: "<p>qwer</p>\n"
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
    }, {attributes: user});

    expect(thread_view.el).toContain('.comment');
    expect(thread_view.el).toContain('a.micro_avatar');
  });

});

