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
    this.el.hide();

    return this;
  };

  /* Hide private elements area
   */
  PrivateElements.reset = function() {
    this.el.hide();
  };

  PrivateElements.updatePrivateUsers = function(event) {
    var el = event.target;
    this.el.down('.private_users').select('.private_user input').each(function(fe){ fe.checked = el.checked; });
  };

  PrivateElements.updateAllUsers = function(event) {
    var users = this.el.down('.private_users');
    users.down('.private_all input').checked = this.allUsersEnabled();
  };

  PrivateElements.toggle = function(event) {
    event.stop();
    var el = event.target
    , options = this.el;

    if (options.visible()) {
      options.select('input').invoke('disable');
      options.hide();
    } else {
      options.select('input').invoke('enable');
      options.show();
    }
  };


  /* Activate Private Elements for pages
  * TODO: Update for backbone
   */
  PrivateElements.activateForPages = function () {

    if (document.body.hasClassName('edit_pages') || document.body.hasClassName('new_pages')) {
      var form = $(document.body).down('.content').down('form');
      this.activate();
      this.update(form.down('div'));
      form.down('.private_options').select('input').invoke('enable');
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
    var private_option = this.el.down('.option.private input')
    , i18n = I18n.translations;

    if (private_option) {
      var text = this.people().length == 1 ? i18n.comments['private']['private_foreveralone'] : i18n.comments['private']['private'];
	    this.el.down('.option.private label').update(text);
    }

    this.redrawBox();
  };

  /* Update Private Elements selections
   */
  PrivateElements.update = function () {
    this.el.update('');
    this.activate();

    var watchers = this.watchers();
    if (!this.model.get('watchers') && watchers) {
      this.model.attributes.watchers = watchers;
    }

    this.el.writeAttribute({
      'object-prefix': this.model.prefix()
    , 'object-type': this.model.className().toLowerCase() + "[comments_attributes][0]"
    });

    this.handleOptionChange();

    if (this.el.visible()) {
      this.el.select('input').invoke('enable');
    }

    return this;
  };

  PrivateElements.allUsersEnabled = function() {
	  var count = 0
    , box = this.el
    , private_users = box.down('.private_users')
    , users = private_users.select('.private_user input');

    users.each(function(fe){ if (fe.checked) count += 1 })
    return count == users.length
  };

  PrivateElements.updateAllUsersEnabled = function() {
    var box = this.el
    , users = box.down('.private_users');
    users.down('.private_all input').checked = this.allUsersEnabled();
  };

  PrivateElements.findUser = function(user_id) {
    return this.people().detect(function(person) {
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
    var box = this.el;
    box.select('.private_users').invoke('remove');
    box.select('.readonly_warning').invoke('remove');

    var watcher_ids = this.model.get('watchers')
    , is_private = this.model.get('is_private')
    , creator_id = this.model.get('user_id')
    , assigned_id = this.model.get('assigned_id');

    // Update buttons & people list
    // TODO: which form?
    var watchers = this.comment_form.el.down('.watchers') // see new conversation form
    , private_input = box.down('.option.private input')
    , public_input = box.down('.option.normal input')
    , i18n = I18n.translations;

    if (private_input && private_input.checked) {
      box.insert({ bottom: this.peopleHTML() });
      //TODO: What's this?
      if (watchers) {
        watchers.select('input').invoke('disable');
        watchers.hide();
      }

      // Update All input
      this.updateAllUsersEnabled();
    } else if (private_input && watchers) {
      watchers.select('input').invoke('enable');
      watchers.show();
    } else if (!private_input && is_private) {
      box.insert({ bottom: this.peopleShowHTML() 
      });
      var creator = this.findUser(creator_id);
      if (creator)
        var user = new Teambox.models.User(creator.get('user'))
        , warning = i18n.comments['private']['readonly_warning']
        , user_link = user.full_name_template(creator.get('user'));

        box.insert({ 
          bottom: '<p class="readonly_warning">' + I18n.t(warning, {user: user_link}) + '</p>'
        });
    }
  };

  PrivateElements.activate = function(can_modify){
    var can_modify = this.model.get('user_id') === Teambox.models.user.id
    , private_set = this.model.get('is_private');

    if (can_modify) {
      this.el.insert({bottom: this.private_box_template({
        object_prefix: this.model.prefix(),
        object_type: this.model.type(),
        is_public: I18n.translations.comments['private']['public'],
        is_private: I18n.translations.comments['private']['private']
      })});

      if (private_set)
        this.el.down('.option.private input').checked = true;
      else
        this.el.down('.option.normal input').checked = true;
    } else {
      // readonly display of watchers
      this.el.insert({bottom: this.private_box_readonly_template({
        is_public: I18n.translations.comments['private']['public'],
        is_private: I18n.translations.comments['private']['private_global']
      })});

      if (private_set)
        this.el.down('.option.normal').hide();
      else
        this.el.down('.option.private').hide();
    }
  };

  // exports
  Teambox.Views.PrivateElements = Backbone.View.extend(PrivateElements);
}());
