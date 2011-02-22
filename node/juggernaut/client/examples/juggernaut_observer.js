// Assumes you're using SuperModel
// http://github.com/maccman/supermodel-js

jQuery(function($){
  var jug = new Juggernaut;
  jug.subscribe("/sync/your_user_id", function(sync){
    var klass = eval(sync.klass);
    switch(sync.type) {
      case "create":
        klass.create(sync.record);
        break;
      case "update":
        klass.update(sync.id, sync.record);
        break;
      case "destroy":
        klass.destroy(sync.id);
        break;
      default:
        throw("Unknown type:" + type);
    }
  });
})