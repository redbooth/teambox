//= require <prototype>
//= require <builder>
//= require <effects>
//= require <controls>
//= require <dragdrop>
//= require <lowpro>
//= require <cropper>
//= require <weakling>
//= require <fyi>
//= require <fancyzoom>

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
  ".column_settings:mouseout": function(e){
    image_source = $(this).src
    $(this).src = image_source.sub(/trash.*\.jpg/,'trash.jpg')    
  },  
  ".column_settings:mouseover": function(){
    $(this).down('.toggle').className = 'toggle toggle_hover';
  },
  ".column_settings:mouseout": function(){
    $$('.column_settings .toggle').each(function(e){ e.className = 'toggle'; });
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
  auto_focus: function(element){
    element = $(element);
    var field;
    if (field = element.down(".focus")) { (function() { try { field.focus() } catch (e) { } }).defer(); }
    return element;
  },
  auto_select: function(element){
    element = $(element);
    var field;
    if (field = element.down(".focus")) { (function() { try { field.select() } catch (e) { } }).defer(); }
    return element;
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

