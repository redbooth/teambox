Event.addBehavior({
  "#people_project_select:change": function(e){
	var el = $(this);
    var value = el.getValue();
    if (value == 0)
    {
      $('sidebar_people').update('');
      $('people_project_load').hide();
    }
    else
    {
      new Ajax.Request(el.readAttribute('people_url'), {
	    asynchronous: true,
	    evalScripts: true,
	    method: 'get',
	    parameters:'pid='+value,
	    onComplete:function(e){
	      $('people_project_load').hide();
	    } 
	  });
	  $('people_project_load').show();
    }
  }
});

Person = {
  watch_role: function(){
    //$$('.roles .role').each(function(e){ 
    //  e.observe('click', Person.change_role)
    //});
    $$('.roles .role input').each(function(e){ 
      e.observe('click', Person.change_role_by_radio)
    });    
  },
  change_role: function(e){
    $$('.roles .active').each(function(ee){ ee.removeClassName('active') })
    $$('.roles input').each(function(ee){ ee.checked = false })
    var ee = e.element()  
    ee.down('input').checked = true;
    ee.addClassName('active');
  },
  change_role_by_radio: function(e){
    $$('.roles .active').each(function(ee){ ee.removeClassName('active') })
    var ee = e.element()  
    ee.up('.role').addClassName('active');
  }
}
