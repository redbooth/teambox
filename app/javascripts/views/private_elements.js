(function () {

  var PrivateElements = { 
      tag: 'div'
    , className: 'private_options'
    , people_show_template: Teambox.modules.ViewCompiler('partials.private_elements_show_people')
    , people_template: Teambox.modules.ViewCompiler('partials.private_elements_people')
    , private_box_template: Teambox.modules.ViewCompiler('comments.private_box')
    , private_box_readonly_template: Teambox.modules.ViewCompiler('comments.private_box_readonly')
  };

  /*
  */
  PrivateElements.events = {
      'change  .private_options .option.normal input' : 'handleOptionChange'
    , 'change  .private_options .option.private input': 'handleOptionChange'
    , 'change  .private_users .private_all input'     : 'updatePrivateUsers'
    , 'change  .private_users .private_user input'    : 'updateAllUsers'
  };

  PrivateElements.initialize = function (options) {
    _.bindAll(this, "render", "update");
    options = options || {};

    this.comment_form = options.comment_form;
    this.model = options.model;
    // TODO: Perhaps this isn't required CommentForm | rest of site?
    // this.activateForPages();
  };

  /* Render private elements area
   */
  PrivateElements.render = function () {
    this.update();
    jQuery(this.el).hide();

    return this;
  };

  /* Hide private elements area
   */
  PrivateElements.reset = function() {
    jQuery(this.el).hide();
  };

  PrivateElements.updatePrivateUsers = function(event) {
    var el = event.target;
    this.$('.private_users .private_user input').each(function(i,fe){ fe.checked = el.checked; });
  };

  PrivateElements.updateAllUsers = function(event) {
    var users = this.$('.private_users');
    users.find('.private_all input').checked = this.allUsersEnabled();
  };

  PrivateElements.toggle = function(event) {
    event.preventDefault();
    var el = jQuery(event.currentTarget)
    , options = jQuery(this.el);

    if (options.is(":visible")) {
      options.find('input').attr('disabled', true);
      options.hide();
    } else {
      options.find('input').attr('disabled', false);
      options.show();
    }
  };


  /* Activate Private Elements for pages
  * TODO: Update for backbone
   */
  PrivateElements.activateForPages = function () {

    var body = jQuery(document.body);
    if (body.hasClass('edit_pages') || body.hasClass('new_pages')) {
      var form = body.find('.content form');
      this.activate();
      this.update(form.find('div'));
      form.find('.private_options input').attr('disabled', false);
    }

    return this;
  };

  /*
  * Returns all people belonging to this model's project
  * @return (Array)
  */
  PrivateElements.people = function() {
    var project_id = this.model.get('project_id');
    return project_id ? Teambox.collections.projects.get(project_id).attributes.people.models : [];
  };

  /*
  * Returns all user ids belonging to this model's project
  * @return (Array)
  */
  PrivateElements.watchers = function() {
    var watchers = _.map(this.people(), function(model) {
      return model.get('user').id;
    });
    return _.isEmpty(watchers) ? false : watchers;
  };

  PrivateElements.handleOptionChange = function() {
    var private_option = this.$('.option.private input')
    , i18n = I18n.translations;

    if (private_option) {
      var text = this.people().length == 1 ? i18n.comments['private']['private_foreveralone'] : i18n.comments['private']['private'];
      this.$('.option.private label').html(text);
    }

    this.redrawBox();
  };

  /* Update Private Elements selections
   */
  PrivateElements.update = function () {
    jQuery(this.el).empty();
    this.activate();

    var watchers = this.watchers();
    if (!this.model.get('watchers') && watchers) {
      this.model.attributes.watchers = watchers;
    }

    this.el.writeAttribute({
      'object-prefix': this.model.prefix
    , 'object-type': this.model.className().toLowerCase() + "[comments_attributes][0]"
    });

    this.handleOptionChange();

    // TODO: Prototype
    if (this.el.visible()) {
      jQuery(this.el).find('input').attr('disabled', false);
    }

    return this;
  };

  PrivateElements.allUsersEnabled = function() {
    var count = 0
    , box = jQuery(this.el)
    , private_users = box.find('.private_users')
    , users = private_users.find('.private_user input');

    users.each(function(fe){ if (fe.checked) count += 1 })
    return count == users.length
  };

  PrivateElements.updateAllUsersEnabled = function() {
    var box = jQuery(this.el)
    , users = box.find('.private_users');
    users.find('.private_all input').each( function(i,el) { el.checked = this.allUsersEnabled(); });
  };

  PrivateElements.findUser = function(user_id) {
    return _(this.people()).detect(function(person) {
      return person.get('user_id') === user_id;
    });
  };

  PrivateElements.peopleShowHTML = function() {
    var people = this.people();
    return this.people_show_template({people: people, watcher_ids: this.model.get('watchers')});
  };

  PrivateElements.peopleHTML = function() {
    return this.people_template({model: this.model, people: this.people(), watcher_ids: this.model.get('watchers'), assigned_id: this.model.get('assigned_id')});
  };

  PrivateElements.redrawBox = function() {
    var box = jQuery(this.el);
    box.find('.private_users, .readonly_warning').remove();

    var watcher_ids = this.model.get('watchers')
    , is_private = this.model.get('is_private')
    , creator_id = this.model.get('user_id')
    , assigned_id = this.model.get('assigned_id');

    // Update buttons & people list
    // TODO: which form?
    var watchers = this.comment_form.form.find('.watchers') // see new conversation form
    , private_input = box.find('.option.private input')
    , public_input = box.find('.option.normal input')
    , i18n = I18n.translations;

    if (private_input && private_input.checked) {
      box.append(this.peopleHTML());
      //TODO: What's this?
      if (watchers) {
        watchers.find('input').attr('disabled', true);
        watchers.hide();
      }

      // Update All input
      this.updateAllUsersEnabled();
    } else if (private_input && watchers) {
      watchers.find('input').attr('disabled', false);
      watchers.show();
    } else if (!private_input && is_private) {
      box.append(this.peopleShowHTML());
      var creator = this.findUser(creator_id);
      if (creator)
        var user = new Teambox.models.User(creator.get('user'))
        , warning = i18n.comments['private']['readonly_warning']
        , user_link = user.full_name_template(creator.get('user'));

        box.append( 
          '<p class="readonly_warning">' + I18n.t(warning, {user: user_link}) + '</p>'
        );
    }
  };

  PrivateElements.activate = function(can_modify){
    var can_modify = this.model.get('user_id') === Teambox.models.user.id
    , private_set = this.model.get('is_private');

    if (can_modify) {
      jQuery(this.el).append(this.private_box_template({
        object_prefix: this.model.prefix,
        object_type: this.model.type,
        is_public: I18n.translations.comments['private']['public'],
        is_private: I18n.translations.comments['private']['private']
      }));

      if (private_set)
        this.$('.option.private input').each( function(i,el) { el.checked = true; } );
      else
        this.$('.option.normal input').each( function(i,el) { el.checked = true; } );
    } else {
      // readonly display of watchers
      jQuery(this.el).append(this.private_box_readonly_template({
        is_public: I18n.translations.comments['private']['public'],
        is_private: I18n.translations.comments['private']['private_global']
      }));

      if (private_set)
        this.$('.option.normal').hide();
      else
        this.$('.option.private').hide();
    }
  };

  // exports
  Teambox.Views.PrivateElements = Backbone.View.extend(PrivateElements);
}());
