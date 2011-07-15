var test = $j();

test([
  function setup() {
    this.user = {some: 'object'};
  }
, function test_user_has_property(assert) {
    assert(this.user.some === 'object');
    assert(!this.user.other);
  }
, function teardown() {
    this.user = null;
  }
]);

test([
  function setup() {
    this.foo = [1, 2, 3];
  }
, function test_user_has_property(assert) {
    assert(this.foo.length === 3);
    assert(this.foo[2] > 934); // Should fail at line 27

    this.foo[1] = 99;

    assert(this.foo[1] !== 2);
  }
, function teardown() {
    this.bar = 'something';
  }
]);

test([
  function test_title(assert) {
    assert(window.document.title, 'Design projects');
  }
]);

test();
