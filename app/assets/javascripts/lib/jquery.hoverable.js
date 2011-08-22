/*
 * jQuery Hoverable Plugin
 * Copyright 2011, Pablo Villalba
 * Licensed under the MIT license
 *
 * Finds any elements on the page with the .hoverable class
 * and wraps them with some HTML when hovered.
 *
 * Before mousehover:
 * <a href="#uploads" title="Upload a file" class="hoverable"></a>
 *
 * After mousehover:
 * <div class="hoverbox">
 *   <a href="#uploads" class="hoverable"></a>
 *   <div class="arrow"></div>
 *   <div class="panel">Upload a file</div>
 * </div>
 *
 */

jQuery(".hoverable").live("mouseover", function(e) {
  var el = jQuery(e.currentTarget);
  if (!el.parent('.hoverbox').length) {
    var hoverbox = jQuery("<div class='hoverbox'></div>");
    hoverbox.addClass(el.attr('data-hoverable-class'));
    el.wrap(hoverbox);
    el.parent('.hoverbox')
      .append("<div class='arrow'></div>")
      .append("<div class='panel'>"+el.attr('title')+"</div>");
    el.attr('title', null);
  }
});

