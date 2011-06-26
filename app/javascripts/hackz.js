//temporary hack to fix jquery throwing errors on null responses (think head :ok)
jQuery.ajaxSetup({ 
    dataFilter: function(data, type){ return (!data || jQuery.trim(data)=="") ? "{}" : data; } 
  , complete:  function(req, status) {
      var inputs = $(document.body).select("input[type=submit][disabled=true][data-disable-with]");
      inputs.each(function(input) {
        input.value = input.readAttribute('data-original-value');
        input.writeAttribute('data-original-value', null);
        input.disabled = false;
      });
  }
});

