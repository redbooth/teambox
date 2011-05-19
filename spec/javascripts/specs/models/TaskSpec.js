/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("models/task", function () {

  var Task = Teambox.Models.Task
    , makeDate = function (offset) {
        return _.now().add({d: offset}).format('YYYY-MM-DD');
      }
    , tasks = [];

  beforeEach(function () {
    tasks[0] = new Task({due_on: makeDate(-30)});
    tasks[1] = new Task({due_on: makeDate(1)});
    tasks[2] = new Task({due_on: makeDate(0)});
  });

  it('`overdue` should get the exceeded days', function () {
    expect(tasks[0].overdue()).toEqual(30);
    expect(tasks[1].overdue()).toEqual(-1);
    expect(tasks[2].overdue()).toEqual(0);
  });

  it('`is_overdue` should get if the task is overdue', function () {
    expect(tasks[0].is_overdue()).toBeTruthy();
    expect(tasks[1].is_overdue()).toBeFalsy();
    expect(tasks[2].is_overdue()).toBeFalsy();
  });

  it('`is_due_today` should get if the task is due today', function () {
    expect(tasks[0].is_due_today()).toBeFalsy();
    expect(tasks[1].is_due_today()).toBeFalsy();
    expect(tasks[2].is_due_today()).toBeTruthy();
  });

  it('`is_due_tomorrow` should get if the task is due tomorrow', function () {
    expect(tasks[0].is_due_tomorrow()).toBeFalsy();
    expect(tasks[1].is_due_tomorrow()).toBeTruthy();
    expect(tasks[2].is_due_tomorrow()).toBeFalsy();
  });

  it('`is_due_in` should get if the task is due in a certain amount of ms', function () {
    var one_day = 1000 * 60 * 60 * 24;

    expect(tasks[0].is_due_in(7 * one_day)).toBeFalsy();
    expect(tasks[1].is_due_in(1 * one_day)).toBeTruthy();
    expect(tasks[1].is_due_in(2 * one_day)).toBeFalsy();
    expect(tasks[2].is_due_in(0)).toBeTruthy();
    expect(tasks[2].is_due_in(2 * one_day)).toBeFalsy();
  });
});


