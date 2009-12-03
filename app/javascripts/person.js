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