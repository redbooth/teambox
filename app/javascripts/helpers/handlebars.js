Handlebars.registerHelper('downcase', function(str) {
  return str.toLowerCase();
});

// Edit this to use other hosts, like https://l.teambox.com
Handlebars.registerHelper('host', '');

Handlebars.registerHelper('full_name', function(user) {
  user = user || this;
  return user.first_name + " " + user.last_name;
});

Handlebars.registerHelper('ms', function(time) {
  return Date.parse(time);
});

// Render status transitions in comments
Handlebars.registerHelper('status_transition', function() {
  var status = $w('new open hold resolved rejected')
    .collect(function(s) {
      return '<span class="task_status task_status_'+s+'">'+s+'</span>';
    });
  var before = status[this.previous_status];
  var now = status[this.status];
  var html = [before, now].compact().join('<span class="arr status_arr"> &rarr; </span>');
  return new Handlebars.SafeString(html);
});

// Register helpers
Handlebars.registerPartial("comment", Templates.partials.comment);
Handlebars.registerPartial("thread", Templates.partials.thread);
Handlebars.registerPartial("comment_form", Templates.partials.comment_form);
