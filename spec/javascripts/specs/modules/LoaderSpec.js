/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("Loader()", function () {

  var Loader = Teambox.modules.Loader
    , callback
    , loader;

  beforeEach(function () {
    callback = sinon.spy();

    setFixtures("<body><div class='loading'><div class='bar'><div class='fill'></div></div></div></body>");
    loader = Loader(callback);
  });

  it('should set body class and loading bar style', function () {
    expect($$('body')[0]).toHaveClass('loading');
    expect($$('.loading .bar .fill')[0]).toHaveAttr('style', 'width: 10px;');
  });

  it('should be initialized with `loaded` and `total`', function () {
    expect(loader.loaded).toEqual(0);
    expect(loader.total).toEqual(0);
  });

  describe("loader#load", function () {
    var callbacks = {}
      , req = ['fleiba', 'zemba'];

    beforeEach(function () {
      _.each(req, function (val) {
        callbacks[val] = loader.load(val);
      });
    });

    it('should increase `total` and return a callback', function () {
      _.each(req, function (val) {
        expect(_.isFunction(callbacks[val])).toBeTruthy();
      });
      expect(loader.loaded).toEqual(0);
      expect(loader.total).toEqual(2);
    });

    describe("loader#load callback called uncomplete", function () {
      it('should increase `loaded` and update the loading bar style', function () {
        callbacks.fleiba();
        expect(loader.loaded).toEqual(1);
        expect(loader.total).toEqual(2);
        expect($$('.loading .bar .fill')[0]).toHaveAttr('style', 'width: 200px;');
        expect(callback).not.toHaveBeenCalled();
      });
    });

    describe("loader#load callback called complete", function () {
      it('should increase `loaded` and return to the `Loader#callback`', function () {
        _.each(req, function (val) {
          callbacks[val]();
        });
        expect(callback).toHaveBeenCalled();
        expect($$('body')[0]).not.toHaveClass('loading');
      });
    });
  });
});
