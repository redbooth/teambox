/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("views/task", function () {

  var TaskView = Teambox.Views.Task
    , TaskModel = Teambox.Models.Task
    , makeDate = function (offset) {
        return _.now().add({d: offset}).format('YYYY-MM-DD');
      };

  it('`getClasses` should get the appropiated classes', function () {
    var task, view;

    task = new TaskModel({due_on: makeDate(1), status_name: 'fleiba', assigned: false});
    view = new TaskView({model: task});

    expect(view.getClasses()).toEqual('due_tomorrow status_fleiba status_notopen due_on unassigned');

    task = new TaskModel({due_on: makeDate(50), status_name: 'zemba', assigned: {user_id: 2}, 'open?': true});
    view = new TaskView({model: task});

    expect(view.getClasses()).toBe('due_week due_2weeks due_3weeks due_month status_zemba due_on assigned user_2');
    task = new TaskModel({due_on: makeDate(-2), status_name: 'foo', assigned: {user_id: 3}});
    view = new TaskView({model: task});

    expect(view.getClasses()).toBe('overdue status_foo status_notopen due_on assigned user_3');

    task = new TaskModel({status_name: 'bar', assigned: {user_id: 4}, 'open?': true});
    view = new TaskView({model: task});

    expect(view.getClasses()).toBe('unassigned_date status_bar assigned user_4');
  });

  it('`render`', function () {
  });

});
