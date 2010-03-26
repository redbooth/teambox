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
  },
  "a.invite_user:click": function(e){
    var el = $(this);
    var form = $('new_invitation');
    var role = $('invitation_role').getValue();
    new Ajax.Request(form.readAttribute('action'), {
      asynchronous: true,
      evalScripts: true,
      method: 'post',
      parameters:{'invitation[user_or_email]':el.readAttribute('login') , 'invitation[role]':role} 
    });
	Effect.DropOut(el.up('.invite_user_link'));
  }
});
