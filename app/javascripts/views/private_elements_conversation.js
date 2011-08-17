(function() {

  var PrivateElementsConv = {
      tag: 'div'
    , className: 'private_options'
    , template: Teambox.modules.ViewCompiler('partials.private_elements')
  };

  PrivateElementsConv.events = {
      'change .privacy select' : 'updateVisibleTo'
  };

  PrivateElementsConv.initialize = function(options) {
    _.bindAll(this, 'render', 'toggle', 'updateVisibleTo');

    this.visible = false;
  };

  PrivateElementsConv.render = function() {
    var self = this;

    var project_id = this.model.get('project_id');
    var people = project_id ? Teambox.collections.projects.get(project_id).attributes.people.models : [];

    this.el
      .hide()
      .update(this.template({
        people: people
      }))
      .down('.people')
        .hide();

    (function() {
      new Chosen(self.el.down('.chzn-select'));
    }).defer();

    return this;
  };

  // Show or hide the whole form relative to privacity
  PrivateElementsConv.toggle = function(event) {
    event.stop();
    if (this.visible) {
      this.el.hide();
    } else {
      this.el.show();
    }
    this.visible = !this.visible;
  };

  // Show or hide the 'Visible to' part
  PrivateElementsConv.updateVisibleTo = function(event) {
    var private = event.srcElement.value;
    var visibleto_el = this.el.down('.people');

    if (private === 'true') {
      visibleto_el.show();
    } else {
      visibleto_el.hide();
    }
  };

  PrivateElementsConv.reset = function(event) {
    this.el.hide;
  }

  Teambox.Views.PrivateElementsConv = Backbone.View.extend(PrivateElementsConv);
}());
