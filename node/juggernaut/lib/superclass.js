var JUtils = require("jutils");

SuperClass = module.exports = function(parent){  
  var result = function(){
    this.init.apply(this, arguments);
  };

  result.prototype.init  = function(){};

  if (parent){
    for(var i in parent){
      result[i] = SuperClass.clone(parent[i]);
    }
    for(var i in parent.prototype){
      result.prototype[i] = SuperClass.clone(parent.prototype[i]);
    }
    result._super = parent;
    result.prototype._super = parent.prototype;
  }

  result.fn = result.prototype;

  result.extend = function(obj){
    var extended = obj.extended;
    for(var i in obj){
      result[i] = obj[i];
    }
    if (extended) extended(result)
  };

  result.include = function(obj){
    var included = obj.included;
    for(var i in obj){
      result.fn[i] = obj[i];
    }
    if (included) included(result)
  };
  
  result.proxy = function(func){
    var thisObject = this;
    return(function(){ 
      return func.apply(thisObject, arguments); 
    });
  }
  result.fn.proxy = result.proxy;

  result.fn._class = result;

  return result;
};

SuperClass.clone = function(obj){
  if (typeof obj == "function") return obj;
  if (typeof obj != "object") return obj;
  if (JUtils.isArray(obj)) return JUtils.extend([], obj);
  return JUtils.extend({}, obj);
};