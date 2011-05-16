# Assets [DRAFT]

Documentation draft about `css` and `js`:

  * Coding standards
  * Tests
  * Building process

## JS

### File organization

All javascripts live under `/app/javascripts`
[TODO: some are still on `vendor/sprockets`]
[TODO: get rid of duplicates and unused modules]

    app/
    |-javascripts/
    |---collections/        # Backbone collections
    |---controllers/        # Backbone controllers
    |---helpers/            # Backbone helpers
    |---models/             # Backbone models
    |---modules/            # Modules implemented by us
    |---vendor/             # third party modules
    |---views/              # Backbone views
    |
    |---application.js      # [Sprocket/Jammit] All our code
    |---libs.js             # [Sprocket/Jammit] Contains frameworks and third party modules.
                            # They don't change oftern so they can be cached a lot.

### Namespace

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

### JSHint

JSHint is used with the following flags.
Some options just define a coding standard, but others will help to prevent bugs / memory leaks.
If you use vim, I highly recommend using [jshint.vim](https://github.com/wookiehangover/jshint.vim)

[TODO: there are lots of globals around which can be namespaced or added to the jshint.rc file]

      /*jshint prototypejs: true, browser: true, devel: true, node: true, jquery: true, debug: true,
      forin: true, undef: true, eqeqeq: true, bitwise: true, immed: true, laxbreak: true, noarg: true,
      noempty: true, nonew: true, indent: 2, maxlen: 120, onevar: true */
      /*global Teambox, _, Backbone, Templates, Handlebars */

### Coding standard

  * We will try to stick to JSHint as much as possible, but without being zealots.
  * Comma-first helps to detect missing commas.
  * Private functions and variables start with `_`.
  * Adopt the **module pattern** as much as possible, it helps to avoid global namespace pollution and allows privacy.
    Declaring dependencies as local variables helps the minifiers.

  * [TO REVIEW] variables are under_scored.
  * [TO REVIEW] Methods are camelCased.
  * [TO REVIEW] Constuctors are CamelCased, and the first letter uppercased.

Example:

``` javascript
(function () {
  var FooPrinter = function () { } // constructor
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

## CSS

...
