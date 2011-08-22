if(typeof(I18n) == 'undefined') { I18n = {}; };

I18n.MATCH = /%\{([^\}]+)\}/g
I18n.t = function(key, opts) {
  return key.replace(I18n.MATCH, function(match, subst) {
      return opts[subst]||''
  })
}