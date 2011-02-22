require("fs").readdirSync("./vendor").forEach(function(name){
  require.paths.unshift("./vendor/" + name + "/lib");  
});

require.paths.unshift("./lib");
module.exports = require("./lib/juggernaut");

