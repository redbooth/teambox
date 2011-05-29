/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("collections/threads", function () {

  var ThreadsCollection = Teambox.Collections.Threads
    , threads;

  beforeEach(function () {
    threads = new ThreadsCollection([{id: 1}, {id: 2}, {id: 3}, {id: 4}]);
  });

  it('`fetchNextPage` should append a thread into the activities', function () {
    var stub = sinon.stub(threads, 'fetch', function (obj) {
      expect(obj.data).toEqual('max_id=4');
      expect(obj.add).toEqual(true);
    });

    threads.fetchNextPage();
  });

});
