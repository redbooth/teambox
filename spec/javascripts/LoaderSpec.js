describe("Loader", function () {

  console.log(Teambox);
  var Loader = Teambox.modules.Loader
    , _stubBody = function () {
        return sinon.stub(window, "$$").withArgs('body').return([{}]);
      }
    , _stubLoadingBar = function () {
        return sinon.stub(window, "$$").withArgs('.loading .bar .fill').return([{}]);
      }
    , _callback = function () {
        console.log('called');
      };

  it('should be initialized `loaded` and `total`', function () {
    var body = _stubBody()
      , loading_bar = _stubLoadingBar();

    sinon.spy(body, 'addClassName').withArgs('loading');
    sinon.spy(loading_bar, 'setStyle').withArgs({width: "10px"});

    this.Loader = Loader(_callback);
    expect(this.Loader.loaded).toEqual(0);
    expect(this.Loader.total).toEqual(0);
  });
});
