/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("Loader()", function () {

  var params = Teambox.modules.params
    , url = 'http://zemba.com?foo=bar&zemba[foo]=fleiba';

  it('should get the param if it exists', function () {
    expect(params('foo', url)).toEqual('bar');
    expect(params('zemba[foo]', url)).toEqual('fleiba');
  });

  it("should get null if it doesn't exist", function () {
    expect(params('bar', url)).toBeNull();
    expect(params('zemba', url)).toBeNull();
  });
});

