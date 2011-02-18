// ToggleForm
//
// Callbacks:
//   toggleform:toggle:action_class
//   toggleform:loading:action_class
//   toggleform:failed:action_class
//   toggleform:loaded:action_class
//   toggleform:cancel:action_class
//

var ToggleForm = {
	debug: false,
	
	toggleElement: function(el) {
		ToggleForm.toggle(parseInt(el.readAttribute('new_record')),
		             el.readAttribute('header_id'),
		             el.readAttribute('link_id'),
		             el.readAttribute('form_id'));
	},
	
	// Handles typical toggleform toggles
	toggle: function(new_record, header_id, link_id, form_id) {
		var header = $(header_id);
		var link = $(link_id);
		var form = $(form_id);
		
		if (new_record) {
			if (link)
	        	link.toggle();
	        if (!form.visible())
		      Effect.BlindDown(form_id, { duration: .3 });
		    else
		      Effect.BlindUp(form_id, { duration: .3 });
		} else {
			var formVisible = form.visible();
			
	        if (!formVisible) {
		    	Effect.BlindDown(form_id, { duration: .3 });
				formVisible = true;
			} else {
		    	Effect.BlindUp(form_id, { duration: .3 });
				formVisible = false;
			}
			
			if (header)
			{
	        	if (!formVisible)
			    	Effect.BlindDown(header_id, { duration: .3 });
				else
		    		Effect.BlindUp(header_id, { duration: .3 });
			}
		}

		Form.reset(form_id);

		if (form.hasClassName('form_error'))
		{ 
			form.removeClassName('form_error');
		}

		$$('# ' + form_id + ' .error').each(function(e){e.remove();});

		if (form.getStyle('display') == 'block')
			form.focusFirstElement();
		
		var formClass = "";
		document.fire("toggleform:toggle:" + formClass, {form:form});
	},
	
	// Handles a typical toggleform app_form
	handleForm: function(form) {
		var url = form.readAttribute('action');
		var formClass = form.readAttribute('toggleformtype');
		
		if (ToggleForm.debug)
			console.log('TOGGLE:CB:' + formClass + ' -> ' + url);
		
	    new Ajax.Request(url, {
	      asynchronous: true,
	      evalScripts: true,
	      method: form.readAttribute('method'),
	      parameters: form.serialize(),
	      onLoading: function() {
		  	form.down('.submit').hide();
		  	form.down('img.loading').show();
			document.fire("toggleform:loading:" + formClass, {form:form});
	      },
	      onFailure: function(response) {	
		  	form.down('.submit').show();
		  	form.down('img.loading').hide();
			document.fire("toggleform:failed:" + formClass, {form:form});
	      },
	      onSuccess: function(response){
		    // Handled in the RJS
			document.fire("toggleform:loaded:" + formClass, {form:form});
	      }
	   });
    },

    handleCancelForm: function(form) {
		var formClass = form.readAttribute('toggleformtype');
		ToggleForm.toggleElement(form);
		document.fire("toggleform:cancel:" + formClass, {form:form});
	}
};

// Generic toggleform form
document.on('submit', 'form.toggleform_form', function(e, el) {
  e.stop();
  ToggleForm.handleForm(el);
});

document.on('click', 'a.new_task_list_link', function(e, el) {
  e.stop();
  ToggleForm.toggleElement(el);
});

// toggleform cancel on create
document.on('click', 'a.inline_form_create_cancel', function(e, el) {
  e.stop();
  ToggleForm.handleCancelForm(el.up('form')); // hide form
});

// toggleform cancel on update
document.on('click', 'a.inline_form_update_cancel', function(e, el) {
  e.stop();
  ToggleForm.handleCancelForm(el.up('form')); // hide form
});
