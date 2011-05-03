//temporary hack to fix jquery throwing errors on null responses (think head :ok)
jQuery.ajaxSetup({ dataFilter: function(data, type){ return (!data || jQuery.trim(data)=="") ? "{}" : data; } });
