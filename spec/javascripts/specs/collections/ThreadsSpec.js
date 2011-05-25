/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("collections/threads", function () {

  var ThreadsCollection = Teambox.Collections.Threads
    , threads;

  beforeEach(function () {
    threads = new ThreadsCollection([{id: 1}, {id: 2}, {id: 3}, {id: 4}]);
  });

  it('`fetchNextPage` should append a thread into the activities', function () {
    var stub = sinon.stub(threads, 'fetch');
    // TODO: pull request sinon, bug!
    expect(stub).toHaveBeenCalledWith({data: 'max_id=4', add: true});

    threads.fetchNextPage();
  });

});
