//= require <prototype>
//= require <rails>
//= require <html5>
//= require <builder>
//= require <effects>
//= require <controls>
//= require <dragdrop>
//= require <sound>

// Run the function as soon as it's called, but prevent further calls during `delay` ms
// Example: function.throttle(200) will only run function() once every 200 ms.
// Useful, for example, to avoid constant processing while typing in a live search box.
Function.prototype.throttle = function(delay) {
  var fn = this
  return function() {
    var now = (new Date).getTime()
    if (!fn.lastExecuted || fn.lastExecuted + delay < now) {
      fn.lastExecuted = now
      fn.apply(fn, arguments)
    }
  }
}

// Instead of calling the function immediately, wait at least `delay` ms before calling it.
// Example: function.debounce(200) will only call the function after a 200ms pause.
// Useful, for example, to check an available username (wait to pause typing and check).
Function.prototype.debounce = function(delay) {
  var fn = this
  return function() {
    fn.args = arguments
    fn.timeout_id && clearTimeout(fn.timeout_id)
    fn.timeout_id = setTimeout(function() { return fn.apply(fn, fn.args) }, delay)
  }
}

setTimeout( function() {
  
  times_called_yell = 0
  yell = function() { times_called_yell++ }.throttle(200)
  setTimeout(yell, 0)   // will fire
  setTimeout(yell, 100)
  setTimeout(yell, 250) // will fire
  setTimeout(yell, 300)
  setTimeout(yell, 350)
  setTimeout(yell, 500) // will fire
  setTimeout(function() { console.log(times_called_yell == 3 ? "[OK] Throttle is executed correctly" : "[FAILED] Throttle found args "+times_called_yell) }, 1000)

  times_called_sing = 0
  sing = function() { times_called_sing++ }.debounce(100)
  setTimeout(sing, 50)
  setTimeout(sing, 120) 
  setTimeout(sing, 200) // will fire
  setTimeout(sing, 400)
  setTimeout(sing, 450) // will fire
  setTimeout(function() { console.log(times_called_sing == 2 ? "[OK] Debounce is executed correctly" : "[FAILED] Debounce found args: "+times_called_sing) }, 1000)

  f = function(a,b,c) {
    console.log((a+b+c) == 66 ? "[OK] Throttle accepts args" : "[FAILED] Throttle failed with args: "+a+" "+b+" "+c)
  }.throttle(100)
  f(11,22,33)

  g = function(a,b,c) {
    console.log((a+b+c) == 66 ? "[OK] Debounce accepts args" : "[FAILED] Debounce failed with args: "+a+" "+b+" "+c)
  }.debounce(100)
  g(11,22,33)

  context_object = new Object
  context_object.some = "property"

  context_throttle_test = function() {
    console.log( this.some == "property" ? "[OK] Throttle sets `this` context" : "[FAILED] Throttle context: "+this)
  }.bind(context_object).throttle(100)
  context_throttle_test()

  context_debounce_test = function() {
    console.log( this.some == "property" ? "[OK] Debounce sets `this` context" : "[FAILED] Debounce context: "+this)
  }.bind(context_object).debounce(100)
  context_debounce_test()

}, 1000)

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

// Automatic pagination when .show_more_button is 350px over the bottom
document.on('scroll', function() {
  var link = $$('.show_more_button a.activity_paginate_link').last();
  if(!link) return;

  var view_height = document.viewport.getHeight();
  var link_height = link.viewportOffset().top;
  var refresh_fn = link.onclick;

  if( (link_height < view_height - 350) && !refresh_fn.called) {
    refresh_fn.called = true;
    refresh_fn();
  }
})