/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("helpers/tasks", function () {

  var Tasks = Teambox.helpers.tasks;

  beforeEach(function () {
    setFixtures('<div id="content">'
              + '<div id="1" class="task overdue         task_list_1 status_1 assigned user_4"></div>'
              + '<div id="2" class="task unassigned_date task_list_2 status_1 unassigned"></div>'
              + '<div id="3" class="task overdue         task_list_1 status_1 mine user_2"></div>'
              + '<div id="4" class="task due_tomorrow    task_list_3 status_1 assigned user_3"></div>'
              + '<div id="5" class="task due_today       task_list_2 status_2 unassigned"></div>'
              + '<div id="6" class="task due_month       task_list_1 status_3 unassigned"></div>'
              + '</div>');
  });

  it('`sort` if sorting by `assigned`', function () {
    var sorted = Tasks.sort($$('#content div'), 'assigned');
    expect(sorted[0]).toHaveClass('mine');
    expect(sorted[1]).toHaveClass('assigned');
    expect(sorted[2]).toHaveClass('assigned');
    expect(sorted[3]).toHaveClass('unassigned');
    expect(sorted[4]).toHaveClass('unassigned');
    expect(sorted[5]).toHaveClass('unassigned');
  });

  it('`sort` if sorting by `due_date`', function () {
    var sorted = Tasks.sort($$('#content div'), 'due_date');
    expect(sorted[0]).toHaveClass('overdue');
    expect(sorted[1]).toHaveClass('overdue');
    expect(sorted[2]).toHaveClass('due_today');
    expect(sorted[3]).toHaveClass('due_tomorrow');
    expect(sorted[4]).toHaveClass('due_month');
    expect(sorted[5]).toHaveClass('unassigned_date');
  });

  it('`sort` if sorting by `task_list`', function () {
    var sorted = Tasks.sort($$('#content div'), 'task_list');
    expect(sorted[0]).toHaveClass('task_list_1');
    expect(sorted[1]).toHaveClass('task_list_1');
    expect(sorted[2]).toHaveClass('task_list_1');
    expect(sorted[3]).toHaveClass('task_list_2');
    expect(sorted[4]).toHaveClass('task_list_2');
    expect(sorted[5]).toHaveClass('task_list_3');
  });

  it('`group` if grouping by `assigned`', function () {
    Tasks.group($$('#content div'), 'assigned');

    var sorted = $$('#content div');
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
});
