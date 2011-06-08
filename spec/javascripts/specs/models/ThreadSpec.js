/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("models/thread", function () {

  var Thread = Teambox.Models.Thread
    , threads = [];

  beforeEach(function () {
    threads[0] = new Thread({id: 1, type: 'Conversation', project_id: 10});
    threads[1] = new Thread({id: 2, type: 'Task', project_id: 20});
  });

  it('`url` should get the correct url', function () {
    expect(threads[0].url()).toEqual('/api/1/projects/10/conversations/1');
    expect(threads[1].url()).toEqual('/api/1/projects/20/tasks/2');
  });
});

