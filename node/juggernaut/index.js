path = process.cwd() + "/node/juggernaut/";
require("fs").readdirSync(path + "vendor").forEach(function(name){
  require.paths.unshift(path + "vendor/" + name + "/lib");
});

require.paths.unshift(path + "lib");
module.exports = require(path + "lib/juggernaut");

