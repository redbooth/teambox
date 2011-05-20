/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("views/task", function () {

  var TaskView = Teambox.Views.Task
    , TaskModel = Teambox.Models.Task
    , makeDate = function (offset) {
        return _.now().add({d: offset}).format('YYYY-MM-DD');
      };

  it('`getClasses` should get the appropiated classes', function () {
    var task, view;

    task = new TaskModel({due_on: makeDate(1), status: 1, assigned: false});
    view = new TaskView({model: task});

    expect(view.getClasses()).toEqual('due_tomorrow status_1 status_notopen due_on unassigned');

    task = new TaskModel({due_on: makeDate(50), status: 2, assigned: {user_id: 2}, 'open?': true});
    view = new TaskView({model: task});

    expect(view.getClasses()).toBe('due_week due_2weeks due_3weeks due_month status_2 due_on assigned user_2');
    task = new TaskModel({due_on: makeDate(-2), status: 3, assigned: {user_id: 3}});
    view = new TaskView({model: task});

    expect(view.getClasses()).toBe('overdue status_3 status_notopen due_on assigned user_3');

    task = new TaskModel({status: 4, assigned: {user_id: 4}, 'open?': true});
    view = new TaskView({model: task});

    expect(view.getClasses()).toBe('unassigned_date status_4 assigned user_4');
  });

  it('`render`', function () {
  });

});
