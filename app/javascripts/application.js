//= require <prototype>
//= require <builder>
//= require <effects>
//= require <controls>
//= require <dragdrop>
//= require <sound>
//= require <lowpro>
//= require <cropper>
//= require <weakling>
//= require <fyi>
//= require <calendar_date_select>
//= require <facebox>

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
  },
  showPreview: function(element) {
    var form = $(element);
    var block = form.down('.showPreview');
    if (block.readAttribute('showing') == '1')
      return false;

    var button = block.down('button');
    var cancel = block.down('a');

    // Set showing, cancel any removals
    block.writeAttribute('showing', '1');
    button.disabled = true;
    button.down('.default').hide();
    button.down('.showing').show();
    if (block.readAttribute('removing') == '1') {
      block.writeAttribute('removing', '0');
      return element;
    }

    // New updater needed!
    var previewBox = form.down('.previewBox');
    var updater = null;
    var updaterCallback = function(transport) {
      if (block.readAttribute('removing') == '1') {
        block.writeAttribute('removing', '0');
        updater.stop();
      } else {
        previewBox.innerHTML = transport.responseText;
        if (!previewBox.visible()) {
          previewBox.blindDown({duration: 0.3});
          button.hide();
          cancel.show();
        }
      }
    }

    updater = new Ajax.PeriodicalFormUpdater(previewBox, form, form.readAttribute('preview'), {
      method: 'post',
      frequency: 2,
      decay: 2,
      onSuccess: updaterCallback,
      onFailure: updaterCallback
    });

    return element;
  },
  closePreview: function(element) {
    var form = $(element);
    var block = form.down('.showPreview');
    if (block.readAttribute('showing') == '0')
      return element;

    var button = block.down('button');
    var cancel = block.down('a');
    var previewBox = block.up('form').down('.previewBox');

    cancel.hide();
    button.down('.default').show();
    button.down('.showing').hide();
    button.show().disabled = false;

    block.writeAttribute('showing', '0');
    block.writeAttribute('removing', '1');
    if (previewBox.visible())
      previewBox.blindUp({duration: 0.15});
    return element;
  },
  nextText: function(element, texts) {
    element = $(element);
    var currentText = element.innerHTML;
    var nextIndex = (texts.indexOf(currentText) + 1) % texts.length;
    return texts[nextIndex];
  }
});

Ajax.PeriodicalFormUpdater = Class.create(Ajax.PeriodicalUpdater, {
  initialize: function($super, container, form, url, options) {
    this.form = form;
    $super(container, url, options);
  },

  onTimerEvent: function() {
    this.options.parameters = Form.serialize(this.form);
    this.updater = new Ajax.Updater(this.container, this.url, this.options);
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

document.on('dom:loaded', function() {
  new Cropper.ImgWithPreview('avatar_crop', {
    minWidth: 55,
    minHeight: 55,
    ratioDim: { x: 200, y: 200 },
    displayOnInit: true,
    onEndCrop: function(coords, dimensions) {
      $('x1').value = coords.x1;
      $('y1').value = coords.y1;
      $('x2').value = coords.x2;
      $('y2').value = coords.y2;
      $('crop_width').value = dimensions.width;
      $('crop_height').value = dimensions.height;
    },
    previewWrap: 'avatar_preview',
    onloadCoords: {
      x1: c.x1,
      y1: c.y1,
      x2: c.x2,
      y2: c.y2
    }
  })
})
