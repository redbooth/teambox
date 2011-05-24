var Teambox = {};
_.each(['Models', 'Collections', 'Controllers', 'Views'            // Constructors
      , 'collections', 'controllers', 'models', 'views', 'helpers' // Instances
      , 'modules', 'cache'], function (el) {                       // other
  Teambox[el] = {};
});

