(function  () {

  var ViewCompiler = function (path, content) {
    var template = content
    , jade_opts = { cache: true, self: true};

    if (path) {
      template = Templates;
      _.each(path.split('.'), function (el) {
        template = template[el];
      });

      jade_opts.filename = path;
    }

    // <3 curry
    return function (locals) {
      _.defaults(locals || {}, Teambox.helpers.jade);
      return require('jade').compile(template, jade_opts)(locals);
    };
  };

  // export
  Teambox.modules.ViewCompiler = ViewCompiler;
}());
