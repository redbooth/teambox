(function () {

  var PageTeaser = { tagName: 'div'
             , className: 'page'
             , template: Teambox.modules.ViewCompiler('partials.page_teaser')
             };

  PageTeaser.events = {
  };

  PageTeaser.initialize = function (options) {
    _.bindAll(this, 'render');
  };

  /* updates the element using the template
   *
   * @return self
   */
  PageTeaser.render = function () {
    jQuery(this.el).html(this.template(this.model));
    return this;
  };

  /* Expand/collapse task comment threads inline
   *
   * @param {Event} evt
   */

  // exports
  Teambox.Views.PageTeaser = Backbone.View.extend(PageTeaser);
}());
