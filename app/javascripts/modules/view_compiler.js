(function  () {

  var ViewCompiler = function (path) {
    var template = Templates;

    _.each(path.split('.'), function (el) {
      template = template[el];
    });

    // <3 curry
    return function (locals) {

      _.defaults(locals || {}, Teambox.helpers.jade);

      return require('jade').compile(
        template
      , {filename: path, cache: true, self: true}
      )(locals);
    };
  };

  // export
  Teambox.modules.ViewCompiler = ViewCompiler;
}());
