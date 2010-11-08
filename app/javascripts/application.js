//= require <prototype>
//= require <rails>
//= require <html5>
//= require <builder>
//= require <effects>
//= require <controls>
//= require <dragdrop>
//= require <sound>

// Call this on any function to transform it into a function that will only be called
// once in the given interval. Example: function().throttle(200) for 200ms.
// Useful, for example, to avoid constant processing while typing in a live search box.
Function.prototype.throttle = function(t) {
  var timeout, scope, args, fn = this, tick = function() {
    fn.apply(scope, args)
    timeout = null
  }
  return function() {
    var timeout, fn = this
    if (!timeout) timeout = setTimeout(tick, t)
  }
}

// Call this on any function to transform it into a function that will only be called
// after the first pause lasting at least the given interval.
// Call function().debounce(200) for 200ms. Useful, for example, to check an available username.
Function.prototype.debounce = function(t) {
  var timeout, fn = this
  return function() {
    var scope = this, args = arguments
    timeout && clearTimeout(timeout)
    timeout = setTimeout(function() { fn.apply(scope, args) }, t)
  }
}

Event.onReady = function(fn) {
  if (document.body) fn()
  else document.on('dom:loaded', fn)
}

Event.addBehavior = function(hash) {
  var behaviors = $H(hash)
  behaviors.each(function(pair) {
    var selector = pair.key.split(':'), fn = pair.value
    document.on(selector[1], selector[0], function(e, el) { fn.call(el, e) })
  })
}
Event.addBehavior.reload = Prototype.emptyFunction

function hideBySelector(selector) {
  insertCss(selector + ' {display:none}')
}

function insertCss(css) {
  var head = document.getElementsByTagName('head')[0],
      style = document.createElement('style')
  
  style.setAttribute("type", "text/css")
  
  if (style.styleSheet) { // IE
    style.styleSheet.cssText = css;
  } else { // w3c
    var cssText = document.createTextNode(css);
    style.appendChild(cssText);
  }
  head.appendChild(style)
}

//= require <calendar_date_select>
//= require <facebox>
//= require <showdown>

replace_ids = function(s){
  var new_id = new Date().getTime();
  return s.replace(/NEW_RECORD/g, new_id);
}

Event.addBehavior({
  ".add_nested_item:click": function(e){
    link = $(this);
    template = eval(link.href.replace(/.*#/, ''))
    $(link.rel).insert({ bottom: replace_ids(template) });
    Event.addBehavior.reload();
  },
  ".remove_nested_item:click": function(e){
    link = $(this);
    target = link.href.replace(/.*#/, '.')
    link.up(target).hide();
    if(hidden_input = link.previous("input[type=hidden]")) hidden_input.value = '1'
  }
});

Element.addMethods({
  forceShow: function(element) {
    return $(element).setStyle({ display: 'block' })
  },
  swapVisibility: function(element, other) {
    $(other).forceShow()
    return $(element).hide()
  },
  insertOrUpdate: function(element, selector, content) {
    element = $(element)
    var target = element.down(selector)
    if (!target) {
      var classnames = selector.match(/(?:\.\w+)+/)
      if (classnames) classnames = classnames[0].gsub('.', ' ').strip()
      var id = selector.match(/#(\w+)/)
      if (id) id = id[1]
      var tagName = (classnames || id) ? selector.match(/\w+/)[0] : selector
      target = new Element(tagName, { 'class': classnames, id: id })
      element.insert(target)
    }
    target.update(content)
    return target
  }
})

Project = {
  valid_url: function(){
    var title = $F('project_permalink');
    var class_name = '';
    if(title.match(/^[a-z0-9_\-\.]{5,}$/))
      class_name = 'good'
    else
      class_name = 'bad'

    $('handle').className = class_name;
    Element.update('handle',title)
  }
}

document.on('click', 'a.closeThis', function(e, link) {
  e.preventDefault()
  $(link.parentNode).hide()
})

if (Prototype.Browser.Gecko) {
  document.on('dom:loaded', function() {
    var searchForm = $$('.search_bar form:has(input[name=search])').first()
    if (searchForm) {
      // search opens in another window/tab when Alt+Return is pressed
      searchForm.on('keydown', function(e) {
        if (e.keyCode == Event.KEY_RETURN) {
          if (e.altKey) this.writeAttribute('target', '_blank')
          else this.removeAttribute('target')
        }
      })
      searchForm.down('input[name=search]').
        writeAttribute('title', 'Search with Alt + Enter to open up results in a new window')
    }
  })
}
