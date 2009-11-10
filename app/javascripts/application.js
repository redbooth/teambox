//= require <curvycorners>
//= require <prototype>
//= require <builder>
//= require <effects>
//= require <controls>
//= require <dragdrop>
//= require <lowpro>
//= require <cropper>
//= require <weakling>
//= require <fyi>

Event.addBehavior({
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