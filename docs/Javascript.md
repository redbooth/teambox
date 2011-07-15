# Javascript

Documentation draft about `js`:

## File organization

All javascripts live under `/app/javascripts`
[TODO: some are still on `vendor/sprockets`]
[TODO: get rid of duplicates and unused modules]

    app/
    |-javascripts/
    |---collections/        # Backbone collections
    |---controllers/        # Backbone controllers
    |---helpers/            # Backbone helpers, shared functions between views
    |---models/             # Backbone models
    |---modules/            # Modules implemented by us
    |---vendor/             # third party modules
    |---views/              # Backbone views
    |
    |---application.js      # [Sprocket/Jammit] All our code
    |---libs.js             # [Sprocket/Jammit] Contains frameworks and third party modules.
                            # They don't change oftern so they can be cached a lot.

## Namespace

In order to avoid lots of global variables, we namespace our `js` modules under the `Teambox` namespace

    Teambox
    |-Collections  # Collection constructors
    |-Controllers  # Controller constructors
    |-Models       # Model constructors
    |-Views        # View constructors
    |
    |-collections  # collection instances
    |-controllers  # controller instances
    |-models       # model instances
    |-views        # view instances
    |
    |-modules      # our modules
    |-cache        # client side cache

## JSHint

Some options just define a coding standard, but others will help to prevent bugs / memory leaks.
If you use vim, I highly recommend using [jshint.vim](https://github.com/wookiehangover/jshint.vim)

[TODO: there are lots of globals around which can be namespaced or added to the jshint.rc file]

Recommended options.

      /*jshint prototypejs: true, browser: true, devel: true, node: true, jquery: true, debug: true,
      forin: true, undef: true, eqeqeq: true, bitwise: true, immed: true, laxbreak: true, noarg: true,
      noempty: true, nonew: true, indent: 2, maxlen: 120, onevar: true */
      /*global Teambox, _, Backbone, Templates, Handlebars, Position, Sortable */

## Coding standard

  * We will try to stick to JSHint as much as possible, but without being stupid zealots.
  * Comma-first helps to detect missing commas.
  * Private functions and variables start with `_`.
  * Adopt the **module pattern** as much as possible, it helps to avoid global namespace pollution and allows privacy.
    Declaring dependencies as local variables helps the minifiers.

  * variables are under_scored.
  * Methods are camelCased.
  * Constuctors are CamelCased, and the first letter uppercased.

Example:

``` javascript
(function () {
  var FooPrinter = function () { } // constructor
    , _config = { user: 'bla'
                , pasw: '123'
                , nested: { hey: 'ho'
                          , fleiba: 'hi'
                          }
                }
    , _printStuff = console.log    // dependency, it can be renamed by a minfier
    , _private_var = 'foo';        // private var

  FooPrinter.prototype.printFoo = function () {
    _printStuff(_private_var);
    return this;
  };

  // exports
  Teambox.modules.FooPrinter = FooPrinter;
}())

var FooPrinter = Teambox.modules.FooPrinter
  , my_printer = new FooPrinter();

  my_printer
    .printFoo(); // => foo
    .printFoo(); // => foo
```

## Templating

The templates are generated server side using trimmer + erb.
We compile them client-side using [jade](https://github.com/visionmedia/jade)

In order to make things easier and provide some defaults, there is a module at `app/javascripts/modules/view_compiler`
use it to generate and cache a compiler.

We are using the `self: true` option, so the only variable exposed on your views is `self`
that refers to the `locals` object you passed to the compiler.

``` javascript
// view.jade
p= self.foo
```

``` javascript
// app.js
var compiler = Teambox.modules.ViewCompiler('partials.comment_form');
console.log(compiler({foo: 'bar'}));
```

There are no _helpers_ in jade. Although you can provide some functions on the `locals` object
and they will be available. As a convention, the `view_compiler` will mixin the attributes
found at `app/javascripts/helpers/jade.js`.

You can overwrite any _helper_ by passing a local with the same name.

## Testing

We use [jasmine](pivotal.github.com/jasmine/) + [phantomjs](code.google.com/p/phantomjs/) for testing.
Include your specs under `spec/javascripts/specs` and then add them manually at `spec/javascripts/SpecRunner.html`.
Try to keep the original file hierachy.
Test only one file for each spec.
Stub any AJAX call, or DOM.

[sinon](http://sinonjs.org/), [jasmine-sinon](https://github.com/froots/jasmine-sinon) and [jasmine-prototype](https://github.com/masylum/jasmine-prototype) are included.

To run the tests you must have the app http server running
Use `make test` or open `spec/javascripts/SpecRunner.html` on your browser.
