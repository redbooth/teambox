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
               , type: "Task"
               , hours: null
               , recent_comments: []
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
    comment_form_view = new CommentFormView({model: thread_model, convert_to_task: {toggle: function () {}}});
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
    expect(comment_form_view.el).toHaveAttr('action', thread_model.commentsUrl());
    expect(comment_form_view.el).toHaveAttr('data-project-id', thread_model.get('project_id') + "");
    expect(comment_form_view.el).toHaveAttr('enctype', 'multipart/form-data');
    expect(comment_form_view.el).toHaveAttr('method', 'POST');
    expect(comment_form_view.el).toHaveClass('edit_task');

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

  it('`reset` should reset the form', function () {
    comment_form_view.el.update(
      '<form>'
    + '<textarea>fffuuu</textarea>'
    + '<input type="file" value="it aint possible" />'
    + '<input type="file" value="it aint possible" />'
    + '<input type="text" class="human_hours" value="fffuuuu" />'
    + '<div class="hours_field"></div>'
    + '<div class="upload_area"></div>'
    + '<div class="error"></div>'
    + '<div class="google_docs_attachment">'
    + '<div class="fields"><input name="fffuu" value="fuu" /></div><ul class="file_list"><li>fuu</li></ul>'
    + '</div>'
    + '</form>'
    );

    comment_form_view.reset();

    expect(comment_form_view.el.down('textarea')).toHaveText('');
    expect(comment_form_view.el).not.toContain('input[type=file]');
    expect(comment_form_view.el.down('.human_hours')).toHaveValue('');
    expect(comment_form_view.el.down('.hours_field')).toBeHidden();
    expect(comment_form_view.el.down('.upload_area')).toBeHidden();
    expect(comment_form_view.el).not.toContain('.error');
    expect(comment_form_view.el).not.toContain('.google_docs_attachment .fields input');
    expect(comment_form_view.el).not.toContain('.google_docs_attachment .file_list li');
  });

  it('`toggleAttach` should toggle the upload area', function () {
    var evt = {stop: function () {}}
      , $stop = sinon.stub(evt, 'stop')
      , $highlight;

    comment_form_view.el.update('<form><div class="upload_area"></div></form>');
    $highlight = sinon.stub(comment_form_view.el.down('.upload_area'), 'highlight');

    comment_form_view.toggleAttach(evt);
    expect(comment_form_view.el.down('.upload_area')).toBeHidden();

    comment_form_view.toggleAttach(evt);
    expect(comment_form_view.el.down('.upload_area')).toBeVisible();

    expect($stop).toHaveBeenCalledTwice();
    expect($highlight).toHaveBeenCalledTwice();

    $highlight.restore();
  });

  it('`toggleHours` should toggle the hours field', function () {
    var evt = {stop: function () {}}
      , $stop = sinon.stub(evt, 'stop')
      , $focus;

    comment_form_view.el.update('<form><div class="hours_field"><input /></div></form>');
    $focus = sinon.stub(comment_form_view.el.down('input'), 'focus');

    comment_form_view.toggleHours(evt);
    expect(comment_form_view.el.down('.hours_field')).toBeHidden();

    comment_form_view.toggleHours(evt);
    expect(comment_form_view.el.down('.hours_field')).toBeVisible();

    expect($stop).toHaveBeenCalledTwice();
    expect($focus).toHaveBeenCalledTwice();

    $focus.restore();
  });

  it('`toggleConvertToTask` should toggle the convert to task form', function () {
    var evt = {stop: function () {}}
      , $toggle = sinon.stub(comment_form_view.convert_to_task, 'toggle');

    comment_form_view.toggleConvertToTask(evt);
    expect($toggle).toHaveBeenCalledWith(evt);

    $toggle.restore();
  });

  it('`toggleWatchers` should toggle the the watchers form', function () {
    var evt = {stop: function () {}}
      , $stop = sinon.stub(evt, 'stop');

    comment_form_view.el.update('<form><div class="add_watchers_box"></div></form>');

    comment_form_view.toggleWatchers(evt);
    expect(comment_form_view.el.down('.add_watchers_box')).toBeHidden();

    comment_form_view.toggleWatchers(evt);
    expect(comment_form_view.el.down('.add_watchers_box')).toBeVisible();

    expect($stop).toHaveBeenCalledTwice();
  });

  it('`showCalendar` should instantiate the calendar', function () {
    var evt = {stop: function () {}}
      , $stop = sinon.stub(evt, 'stop')
      , $calendar = sinon.stub(Teambox.modules, 'CalendarDateSelect');

    comment_form_view.el.update('<form><a><input /><span></span></a></form>');

    comment_form_view.showCalendar(evt, comment_form_view.el.down('a'));

    expect($calendar).toHaveBeenCalledOnce();
    expect($stop).toHaveBeenCalledOnce();

    $calendar.restore();
  });

  it('`focusTextarea` should reveal the extra controls and assign the autocompleter', function () {
    var evt = {
        stop: function () {},
        element: function () {
          return comment_form_view.el.down('textarea');
        }
      }
      , project = {foo: 'bar', getAutocompleterUserNames: function () {}}
      , people = {zemba: 'fleiba'}
      , autocompleter = {options: {array: null}}
      , $get_user_names = sinon.stub(project, 'getAutocompleterUserNames').returns(people)
      , $local = sinon.stub(Autocompleter, 'Local').returns(autocompleter);

    Teambox.collections = {projects: {get: function () {
      return project;
    }}};

    comment_form_view.el.update('<textarea></textarea><div class="extra"></div>');

    comment_form_view.focusTextarea(evt);
    comment_form_view.focusTextarea(evt);

    expect(comment_form_view.el.down('.extra')).toBeVisible();
    expect($get_user_names).toHaveBeenCalledTwice();
    expect(comment_form_view.el.down('.autocomplete')).toBeHidden();
    expect($local).toHaveBeenCalledOnce();
    expect(autocompleter.options.array).toEqual(people);

    [$get_user_names, $local].invoke('restore');
  });

  it('`hasFileUploads` should return true if at least one file has uploads', function () {
    // can't be tested
  });

  it('`hasEmptyFileUploads` should return true if at least one file doesnt uploads', function () {
    // can't be tested
  });

  it('`postComment` should upload files if available and sync the model', function () {
    var evt = {stop: function () {}}
      , data = {task: {foo: 'bar'}}
      , response = {im: 'a response'}
      , comment_attributes = {im: 'comments attributez'}
      , $stop = sinon.stub(evt, 'stop')
      , $deparam = sinon.stub(_, 'deparam').returns(data)
      , $reset = sinon.stub(comment_form_view, 'reset')
      , $parse_comments = sinon.stub(comment_form_view.model, 'parseComments').returns(comment_attributes)
      , $save = sinon.stub(comment_form_view.model, 'save', function (_data, _options) {
          _options.success('whatever', response);
          _options.failure('whatever', {errors: [{error: {value: 'foo'}}, {error: {value: 'bar'}}]});
        })
      , $trigger = sinon.stub(comment_form_view.model, 'trigger');

    comment_form_view.el.update('<textarea></textarea><div class="text_area"></div>');

    comment_form_view.postComment(evt);

    expect(comment_form_view.el).toContain('p.error');

    expect($stop).toHaveBeenCalledOnce();
    expect($deparam).toHaveBeenCalledOnce();
    expect($reset).toHaveBeenCalledOnce();
    expect($parse_comments).toHaveBeenCalledWith(response);
    expect($save).toHaveBeenCalledOnce();
    expect($trigger).toHaveBeenCalledWith('comment:added', comment_attributes);
  });
});
