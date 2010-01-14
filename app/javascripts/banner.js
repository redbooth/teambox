Event.addBehavior({
  ".banner_navigation li.calendar:click": function(e){
    // $$(".banner_navigation a").invoke("removeClassName", "active");
    $$(".banner_navigation a").each(function(link){
      link.removeClassName("active");
    })
    $$(".banner_item").invoke("hide");

    $("upcoming_events_banner").show();
    $("calendar_banner_link").addClassName("active");
    alert("hello from calendar!");
  }
  
  // ".banner_navigation li.calendar:click": function(e){
  //   // $$(".banner_navigation a").invoke("removeClassName", "active");
  //   $$(".banner_navigation a").each(function(link){
  //     link.removeClassName("active");
  //   })
  //   $$(".banner_item").invoke("hide");
  // 
  //   $("gantt_banner").show();
  //   $("gantt_banner_link").addClassName("active");
  //   alert("hello from gantt chart!");
  // }
  
});
