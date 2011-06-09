/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("views/comment_form", function () {

  var CommentFormView = Teambox.Views.CommentForm
    , Thread = Teambox.Models.Thread
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
    , thread_model
    , comment_form_view;

  beforeEach(function () {
    setFixtures('');
    thread_model = new Thread(thread);
    comment_form_view = new CommentFormView({model: thread_model});
  });

  it('`render` should render the comment form', function () {

    Teambox.collections = {projects: {get: function () {}}};

    function mock_render() {
      return {el: 'foo'};
    }

    var conversation_model = {}
      , select_status_view = {render: mock_render}
      , select_assigned_view = {render: mock_render}
      , upload_area_view = {render: mock_render}
      , watchers_view = {render: mock_render}
      , project = {foo: 'bar'}

      , $select_status_view = sinon.stub(Teambox.Views, 'SelectStatus').returns(select_status_view)
      , $select_assigned_view = sinon.stub(Teambox.Views, 'SelectAssigned').returns(select_assigned_view)
      , $status_render = sinon.stub(select_status_view, 'render')
      , $assigned_render = sinon.stub(select_assigned_view, 'render')
      , $project = sinon.stub(Teambox.collections.projects, 'get').returns(project)
      , $upload_area_view = sinon.stub(Teambox.Views, 'UploadArea').returns(watchers_view)
      , $watchers_view = sinon.stub(Teambox.Views, 'Watchers').returns(watchers_view);

    expect(comment_form_view.render()).toEqual(comment_form_view);

    expect(comment_form_view.el).toHaveAttr('accept-charset', 'UTF-8');
    expect(comment_form_view.el).toHaveAttr('accept', 'text/plain');
    expect(comment_form_view.el).toHaveAttr('action', thread_model.comments_url());
    expect(comment_form_view.el).toHaveAttr('data-project-id', thread_model.get('project_id') + "");
    expect(comment_form_view.el).toHaveAttr('enctype', 'multipart/form-data');
    expect(comment_form_view.el).toHaveAttr('method', 'POST');
    expect(comment_form_view.el).toHaveClass('edit_comment');

    expect($status_render).toHaveBeenCalled();
    expect($assigned_render).toHaveBeenCalled();
    expect($select_status_view).toHaveBeenCalledWith({
      el: comment_form_view.el.select('#task_status')[0]
    , selected: thread_model.get('status')
    });
    expect($select_assigned_view).toHaveBeenCalledWith({
      el: comment_form_view.el.select('#task_status')[0]
    , project: project
    , selected: thread_model.get('assigned_id')
    });
    expect($project).toHaveBeenCalledWith(thread_model.get('project_id'));
    expect($project).toHaveBeenCalledWith(thread_model.get('project_id'));
    expect($upload_area_view).toHaveBeenCalledWith({comment_form: comment_form_view});
    expect($watchers_view).toHaveBeenCalledWith({model: thread_model});

    [ $select_status_view, $select_assigned_view
    , $status_render, $assigned_render, $project
    , $upload_area_view, $watchers_view ].invoke('restore');
  });
});
