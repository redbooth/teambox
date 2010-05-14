//= require <prototype>
//= require <html5>
//= require <champagne>
//= require <builder>
//= require <effects>
//= require <controls>
//= require <dragdrop>
//= require <sound>

Function.prototype.throttle = function(t) {
  var timeout, scope, args, fn = this, tick = function() {
    fn.apply(scope, args)
    timeout = null
  }
  return function() {
    scope = this
    args = arguments
    if (!timeout) timeout = setTimeout(tick, t)
  }
}

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
  // console.log(behaviors.keys())
  behaviors.each(function(pair) {
    var selector = pair.key.split(':')
    document.on(selector[1], selector[0], pair.value)
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

//= require <weakling>
//= require <fyi>
//= require <calendar_date_select>
//= require <facebox>
//= require <showdown>

replace_ids = function(s){
  var new_id = new Date().getTime();
  return s.replace(/NEW_RECORD/g, new_id);
}

Event.addBehavior({
  ".remove:mouseover": function(e){
    image_source = $(this).src
    $(this).src = image_source.sub(/remove.*\.png/,'remove_hover.png')
  },
  ".remove:mouseout": function(e){
    image_source = $(this).src
    $(this).src = image_source.sub(/remove.*\.png/,'remove.png')
  },
  ".drag:mouseover": function(e){
    image_source = $(this).src
    $(this).src = image_source.sub(/drag.*\.png/,'drag_hover.png')
  },
  ".drag:mouseout": function(e){
    image_source = $(this).src
    $(this).src = image_source.sub(/drag.*\.png/,'drag.png')
  },
  ".pencil:mouseover": function(e){
    image_source = $(this).src
    $(this).src = image_source.sub(/pencil.*\.jpg/,'pencil_hover.jpg')
  },
  ".pencil:mouseout": function(e){
    image_source = $(this).src
    $(this).src = image_source.sub(/pencil.*\.jpg/,'pencil.jpg')
  },
  ".trash:mouseover": function(e){
    image_source = $(this).src
    $(this).src = image_source.sub(/trash.*\.jpg/,'trash_hover.jpg')
  },
  ".trash:mouseout": function(e){
    image_source = $(this).src
    $(this).src = image_source.sub(/trash.*\.jpg/,'trash.jpg')
  },
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
  showPreview: function(element) {
    var form = $(element),
        block = form.down('.showPreview'),
        textarea = form.down('textarea'),
        previewBox = form.down('.previewBox')
        button = block.down('button'),
        cancel = block.down('a');

    button.disabled = true;
    button.down('.default').hide();
    button.down('.showing').show();
    
    var formatter = new Showdown.converter;
    formatter.makeHtml = formatter.makeHtml.wrap(function(make) {
      previewBox.update(make(textarea.getValue()))
    })
    
    textarea.updatePreview = textarea.on('keyup', formatter.makeHtml.bind(formatter).throttle(300))
    
    formatter.makeHtml()
    
    if (!previewBox.visible()) {
      previewBox.blindDown({duration: 0.3});
      button.hide();
      cancel.show();
    }

    return element;
  },
  closePreview: function(element) {
    var form = $(element),
        block = form.down('.showPreview'),
        textarea = form.down('textarea'),
        button = block.down('button'),
        cancel = block.down('a'),
        previewBox = block.up('form').down('.previewBox');

    textarea.updatePreview.stop()
    
    cancel.hide();
    button.down('.default').show();
    button.down('.showing').hide();
    button.show().disabled = false;

    if (previewBox.visible()) previewBox.blindUp({duration: 0.15});
    return element;
  },
  nextText: function(element, texts) {
    element = $(element);
    var currentText = element.innerHTML;
    var nextIndex = (texts.indexOf(currentText) + 1) % texts.length;
    return texts[nextIndex];
  }
});

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

Group = {
  valid_url: function(){
    var title = $F('group_permalink');
    var class_name = '';
    if(title.match(/^[a-z0-9_\-\.]{5,}$/))
      class_name = 'good'
    else
      class_name = 'bad'

    $('handle').className = class_name;
    Element.update('handle',title)
  }
}
