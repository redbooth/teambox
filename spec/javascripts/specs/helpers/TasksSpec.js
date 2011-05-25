/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("helpers/tasks", function () {

  var Tasks = Teambox.helpers.tasks;

  beforeEach(function () {
    setFixtures('<div id="content">'
              + '<div id="1" class="task overdue         task_list_1 status_1 assigned user_4"><div class="project"><a>Fleiba</a></div></div>'
              + '<div id="2" class="task unassigned_date task_list_2 status_1 unassigned"><div class="project"><a>Zemba</a></div></div>'
              + '<div id="3" class="task overdue         task_list_1 status_1 mine user_2"><div class="project"><a>Flow</a></div></div>'
              + '<div id="4" class="task due_tomorrow    task_list_3 status_1 assigned user_3"><div class="project"><a>Mega</a></div></div>'
              + '<div id="5" class="task due_today       task_list_2 status_2 unassigned"><div class="project"><a>Trasca</a></div></div>'
              + '<div id="6" class="task due_month       task_list_1 status_3 unassigned"><div class="project"><a>Haskell</a></div></div>'
              + '</div>');
  });

  it('`getStatus` should get a fn that returns the matching "status"', function () {
    var getStatus = Tasks.getStatus
      , tasks = $$('#content .task');

    expect(getStatus('assigned', 'order')(tasks[0])).toEqual(1);
    expect(getStatus('due_date', 'label')(tasks[0])).toEqual('late tasks');
    expect(getStatus('task_list')(tasks[0])).toEqual({order: 1, label: 'Fleiba'});

    expect(getStatus('assigned')(tasks[1])).toEqual({order: 2, label: 'unassigned'});
    expect(getStatus('due_date', 'order')(tasks[1])).toEqual(7);
    expect(getStatus('task_list', 'label')(tasks[1])).toEqual('Zemba');
  });

  it('`sort` if sorting by `assigned`', function () {
    var sorted = Tasks.sort($$('#content .task'), 'assigned');
    expect(sorted[0]).toHaveClass('mine');
    expect(sorted[1]).toHaveClass('assigned');
    expect(sorted[2]).toHaveClass('assigned');
    expect(sorted[3]).toHaveClass('unassigned');
    expect(sorted[4]).toHaveClass('unassigned');
    expect(sorted[5]).toHaveClass('unassigned');
  });

  it('`sort` if sorting by `due_date`', function () {
    var sorted = Tasks.sort($$('#content .task'), 'due_date');
    expect(sorted[0]).toHaveClass('overdue');
    expect(sorted[1]).toHaveClass('overdue');
    expect(sorted[2]).toHaveClass('due_today');
    expect(sorted[3]).toHaveClass('due_tomorrow');
    expect(sorted[4]).toHaveClass('due_month');
    expect(sorted[5]).toHaveClass('unassigned_date');
  });

  it('`sort` if sorting by `task_list`', function () {
    var sorted = Tasks.sort($$('#content .task'), 'task_list');
    expect(sorted[0]).toHaveClass('task_list_1');
    expect(sorted[1]).toHaveClass('task_list_1');
    expect(sorted[2]).toHaveClass('task_list_1');
    expect(sorted[3]).toHaveClass('task_list_2');
    expect(sorted[4]).toHaveClass('task_list_2');
    expect(sorted[5]).toHaveClass('task_list_3');
  });

  it('`group` if grouping by `assigned`', function () {
    Tasks.group({
      tasks: $$('#content .task')
    , by: 'assigned'
    , where: $('content')
    });

    var sorted = $$('#content > div');
    expect(sorted[0]).toHaveClass('group');
    expect(sorted[1]).toHaveClass('mine');

    expect(sorted[2]).toHaveClass('group');
    expect(sorted[3]).toHaveClass('assigned');
    expect(sorted[4]).toHaveClass('assigned');

    expect(sorted[5]).toHaveClass('group');
    expect(sorted[6]).toHaveClass('unassigned');
    expect(sorted[7]).toHaveClass('unassigned');
    expect(sorted[8]).toHaveClass('unassigned');
  });

  it('`ungroup` should delete all groups made', function () {
    Tasks.group({
      tasks: $$('#content .task')
    , by: 'assigned'
    , where: $('content')
    });
    Tasks.ungroup();

    $$('#content > div').each(function (task) {
      expect(task).not.toHaveClass('group');
    });
  });
});
