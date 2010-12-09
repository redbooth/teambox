Element.addMethods({
  getSlotId: function(element) {
    element = $(element)
    return element.readAttribute('slot') ||
      (element.id && element.id.match(/^page_slot_(\d+)$/) && RegExp.$1)
  }
})

// Page controller object
var Page = {
  SLOT_VERGE_BEFORE: 3,
  SLOT_VERGE_AFTER: 6,
  READONLY: false,

  init: function(readonly, url) {
    this.READONLY = readonly;
    this.url = url;
    document.currentPage = this;
    if (!readonly) {
      InsertHere.init();
      InsertionBar.init();
      InsertHere.set(null, true);

      $($('content').parentNode).observe('mousemove', InsertHereFunc);
    }
  },

  makeSortable: function() {
    if (this.READONLY)
      return;

    Sortable.create('slots', {handle: 'slot_handle', tag: 'div', only: 'page_slot',
      onUpdate: function() {
        var csrf_param = $$('meta[name=csrf-param]').first(),
            csrf_token = $$('meta[name=csrf-token]').first(),
            serialized = Sortable.serialize('slots', {name: 'slots'});
        
        if (csrf_param) {
          var param = csrf_param.readAttribute('content'),
              token = csrf_token.readAttribute('content')
          
          serialized += '&' + param + '=' + token
        }

        new Ajax.Request(Page.url + '/reorder', { parameters: serialized });
      } 
    });
  },

  insertWidget: function(widget_id, pos, element_id, content) {
    var el = $(element_id);
    var opts = {};
    if (!el) {
      // fallback: before/after == top/bottom
      el = $('slots');
      if (pos == 'before')
        opts['top'] = content;
      else if (pos == 'after')
        opts['bottom'] = content;
      else
        opts[pos] = content; // 0_0;
    } else {
      opts[pos] = content;
    }

    el.insert(opts);
    new Effect.Highlight(widget_id, {duration:3});
  }
}

// Insertion bar which appears between slots
var InsertionBar = {
  element: null,
  element_bar: null,
  element_form: null,

  init: function() {
    this.element = $('pageInsertItems');
    this.element_bar  = $('pageInsertItemsBar');
    this.current_form = null;
  },

  show: function() {
    this.place();
    this.element_bar.blindDown({duration: 0.3});
  },

  place: function() {
    InsertHere.element.insert({before: this.element});
  },

  hide: function() {
    this.element_bar.hide();
  },

  revealForm: function() {
    // Reveal form
    this.element_bar.hide();
    this.current_form.show();

    InsertHere.enabled = true;
  },
    
  // Widget form
  setWidgetForm: function(form) {
    this.clearWidgetForm();
    form = $(form);

    // Set insertion position
    form.down('input[name="position[before]"]').setValue(Page.insert_before ? '1' : '0')
    form.down('input[name="position[slot]"]').setValue(Page.insert_element ? Page.insert_element.getSlotId() : '-1')
    // Form should go in the insertion bar, so we can change the insertion location and maintain state
    this.current_form = form;
    this.revealForm();
  },

  setWidgetFormLoading: function(id, active) {
    var form = $(id);
    var submit = form ? form.down('.submit') : null;
    var loading = form ? form.down('.loading') : null;

    if (!(submit && loading)) return;

    if (active) {
      submit.hide();
      loading.show();
    } else {
      submit.show();
      loading.hide();
    }
  },

  clearWidgetForm: function() {
    if (this.current_form) {
      this.current_form.reset();
      this.current_form.hide();
	  this.current_form.fire('ajax:complete');
      this.current_form = null;
    }
  }
};

// Insertion marker which appears between slots
var InsertHere = {
  element: null,
  enabled: false,
  visible: false,

  init: function() {
    this.element = $('pageInsert');
    this.enabled = true;
    this.visible = false;
    Page.insert_element = null;
  },

  show: function(el, insert_before) {
    this.visible = true;
    this.set(el, insert_before);
    this.element.show();
    this.updateSlot(true);
  },

  hide: function() {
    if (this.visible) {
      this.element.hide();
      this.visible = false;
      this.updateSlot(false);
      if (this.enabled)
        this.set(null, true);
    }
  },

  updateSlot: function(active) {
    if (Page.insert_element == null)
      return;
    var el = Page.insert_before ? Page.insert_element : Page.next_element;
    if (el == null)
      return;
    if (active) {
      el.addClassName("InsertBefore");
    } else {
      el.removeClassName("InsertBefore");
    }
  },

  nextSlot: function() {
    if (Page.insert_element == null)
      return;
    var next = Page.insert_element.next();
    while (next != null && !next.getSlotId()) {
      next = next.next();
    }
    return next;
  },

  set: function(element, insert_before) {
    var el = element == null ? $(Element.getElementsBySelector($('slots'), '.page_slot')[0]) : element;
    
    this.updateSlot(false);
    Page.insert_element = el;
    Page.next_element = this.nextSlot();
    Page.insert_before = el ? insert_before : true;
    if (this.visible)
      this.updateSlot(true);

    if (el == null)
      $('slots').insert({bottom: this.element});
    else if (insert_before)
      el.insert({before: this.element});
    else
      el.insert({after: this.element});
  }
};

// Hover observer for InsertHere
var InsertHereFunc = function(evt){
  if (!InsertHere.enabled)
    return;

  var el = $(evt.target);
  if (el.readAttribute('id') == "PIB")
    return;
  var slot = el.hasClassName('page_slot') ? el : el.up('div.page_slot');
  if (!slot)
    return;
  
  var pt = evt.pointer(),
      offset = slot.cumulativeOffset(),
      delta = pt.x - offset.left,
      w = slot.getDimensions().width;
  
  if (delta < (w-32)) {
    // Show bar here *if* we are within the slot
    var h = slot.getHeight(),
        thr_b = Math.min(h / 2, Page.SLOT_VERGE_BEFORE), thr_a = Math.min(h / 2, Page.SLOT_VERGE_AFTER);
    if (slot.hasClassName('pageFooter')) // before footer
      InsertHere.show(slot, true);
    else if (pt.y - offset.top <= thr_b) // before element
      InsertHere.show(slot, true);
    else if ((offset.top + h) - pt.y <= thr_a) // after element
      InsertHere.show(slot, false);
    else
      InsertHere.hide();
  } else {
    InsertHere.hide();
  }
}

document.on('dom:loaded', function() {
  if ($$('body.show_pages').first()) {
    Page.init(false, window.location.pathname);
    Page.makeSortable();
  }
})

// Buttons

document.on('click', 'a.note_button, a.divider_button, a.upload_button', function(e, button) {
  e.preventDefault();
  
  if (!button.up('.pageSlots')) {
    InsertHere.set(null, true);
    InsertionBar.place();
  }
  
  var type = button.className.match(/\b(note|divider|upload)_/)[1];
  
  var form = $('new_' + type);
  InsertionBar.setWidgetFormLoading(form, false);
  InsertionBar.setWidgetForm(form);
  Form.reset(form).focusFirstElement();
});

document.on('click', 'a.cancelPageWidget', function(e) {
  e.stop()
  InsertionBar.clearWidgetForm();
});

document.on('click', '#page_reorder', function(e) {
  e.stop();
  $('page_reorder').hide();
  $('page_reorder_done').show();
  
  Sortable.create('column_pages', {handle: 'drag', tag: 'div', only: 'page',
    onUpdate: function() {
      var csrf_param = $$('meta[name=csrf-param]').first(),
          csrf_token = $$('meta[name=csrf-token]').first(),
          serialized = Sortable.serialize('column_pages', {name: 'pages'});
      
      if (csrf_param) {
        var param = csrf_param.readAttribute('content'),
            token = csrf_token.readAttribute('content')
        
        serialized += '&' + param + '=' + token
      }

      new Ajax.Request($('column_pages').readAttribute('reorder_url'), { parameters: serialized });
    } 
  });
  
  $('column_pages').addClassName('reordering');
});

document.on('click', '#page_reorder_done', function(e) {
  e.stop();
  
  $('column_pages').removeClassName('reordering');
  $('page_reorder').show();
  $('page_reorder_done').hide();
  
  Sortable.destroy('column_pages');
});

document.on('click', '.pageForm a.cancel', function(e, el){
  e.stop();
  el.up('.pageForm').remove();
});

document.on('click', '#pageInsert', function(e, el){
  if (InsertionBar.current_form) {
    InsertionBar.place();
  } else {
    InsertionBar.show();
    InsertHere.enabled = false;
    InsertHere.hide();
  }
});

document.on('click', 'div.page_slot', function(e, el){
  if (!InsertHere.visible)
    return;
  if (InsertionBar.current_form) {
    InsertionBar.place();
  } else {
    InsertionBar.show();
    InsertHere.enabled = false;
    InsertHere.hide();
  }
});

document.on('click', '#pageInsertItemCancel', function(e, el) {
  e.stop();
  InsertionBar.hide();
  InsertHere.enabled = true;
});

// Widget actions, forms

document.on('ajax:before', '.page_slot .actions, .page_slot .slotActions', function(e) {
  e.findElement('a').hide().next('.loading_action').show();
});

document.on('ajax:complete', '.page_slot .actions, .page_slot .slotActions', function(e) {
  e.findElement('a').show().next('.loading_action').hide();
});

document.on('ajax:before', '.page_slot .note form, .page_slot .divider form', function(e, el) {
  el.down('.submit').hide();
  el.down('img.loading').show();
});

document.on('ajax:complete', '.page_slot .note form, .page_slot .divider form', function(e, el) {
  el.down('.submit').show();
  el.down('img.loading').hide();
});

document.on('ajax:create', 'form.edit_note', function(e, element) {
  element.down('img.loading').show()
});

document.on('submit', 'body.show_pages form#new_upload', function(e, form) {
  var iframe = new Element('iframe', { id: 'file_upload_iframe', name: 'file_upload_iframe' }).hide()
  $(document.body).insert(iframe)
  form.target = iframe.id
  form.insert(new Element('input', { type: 'hidden', name: 'iframe', value: 'true' }))
})
