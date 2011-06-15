/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("views/convert_to_task", function () {

  var ConvertToTask = Teambox.Views.ConvertToTask
    , Conversation = Teambox.Models.Conversation
    , conversation = { body_html: "<p>qwer</p>\n"
                     , created_at: "2011-05-30 17:14:55 +0000"
                     , body: "qwer"
                     , target_id: 6
                     , project_id: 1
                     , updated_at: "2011-05-30 17:14:55 +0000"
                     , id: 48
                     , user_id: 1
                     , type: "Task"
                     , hours: null
                     , recent_comments: []
                     , target_type: "Conversation"
                     , project: { id: 1
                                , permalink: 'http://zpeaker.com'
                                , name: 'zpeaker'
                                , models: []
                                , get: function () { }
                                }
                     }
    , conversation_model
    , convert_to_task_view;


  beforeEach(function () {
    setFixtures('');
    conversation_model = new Conversation(conversation);
    Teambox.collections = {projects: {get: function () {
      return conversation.project;
    }}};
    convert_to_task_view = new ConvertToTask({
      model: conversation_model
    , comment_form: {el: new Element('form'), toggle: function () {}}
    });
  });

  it('`render` should render the convert to task form', function () {

    function mock_render() {
      return {el: 'foo'};
    }

    var el = convert_to_task_view.el
      , select_status_view = {render: mock_render}
      , select_assigned_view = {render: mock_render}
      , task_lists = {models: []}

      , $select_status_view = sinon.stub(Teambox.Views, 'SelectStatus').returns(select_status_view)
      , $select_assigned_view = sinon.stub(Teambox.Views, 'SelectAssigned').returns(select_assigned_view)
      , $status_render = sinon.stub(select_status_view, 'render')
      , $assigned_render = sinon.stub(select_assigned_view, 'render')
      , $task_lists = sinon.stub(conversation.project, 'get').returns(task_lists);

    task_lists.models.push({id: 1, get: function () {return 'foo';}});
    task_lists.models.push({id: 2, get: function () {return 'bar';}});

    convert_to_task_view.render();

    expect(el).toHaveAttr('accept-charset', 'UTF-8');
    expect(el).toHaveAttr('method', 'POST');
    expect(el).toHaveAttr('action', conversation_model.convertToTaskUrl());
    expect(el).toBeHidden();
    expect(el.down('#conversation_task_list_id')).toHaveHtml(
      '<option value="1">foo</option><option value="2">bar</option>'
    );


    expect($status_render).toHaveBeenCalled();
    expect($assigned_render).toHaveBeenCalled();
    expect($select_status_view).toHaveBeenCalledWith({
      el: convert_to_task_view.el.select('#conversation_status')[0]
    });
    expect($select_assigned_view).toHaveBeenCalledWith({
      el: convert_to_task_view.el.select('#conversation_assigned_id')[0]
    , selected: null
    , project: conversation.project
    });
    expect($task_lists).toHaveBeenCalled();

    [$select_status_view, $select_assigned_view, $status_render, $assigned_render, $task_lists].invoke('restore');
  });

  it('`toggle` should toggle the `comment` and `convert to task` form', function () {
    var evt = {stop: function () {}}
      , $stop = sinon.stub(evt, 'stop');

    convert_to_task_view.el.hide();

    convert_to_task_view.toggle(evt);
    expect(convert_to_task_view.el).toBeVisible();
    expect(convert_to_task_view.comment_form.el).toBeHidden();

    convert_to_task_view.toggle(evt);
    expect(convert_to_task_view.el).toBeHidden();
    expect(convert_to_task_view.comment_form.el).toBeVisible();

    expect($stop).toHaveBeenCalledTwice();
  });

  it('`convertToTask` should sync the action to the server', function () {
    var evt = {stop: function () {}}
      , $stop = sinon.stub(evt, 'stop')
      , $convert_to_task = sinon.stub(conversation_model, 'convertToTask');

    convert_to_task_view.convertToTask(evt);

    expect($stop).toHaveBeenCalledOnce();
    expect($convert_to_task).toHaveBeenCalledOnce();
  });
});
