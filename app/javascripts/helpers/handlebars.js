Handlebars.registerHelper('downcase', function (str) {
  return str.toLowerCase();
});

Handlebars.registerHelper('short_name', function (user) {
  user = user || this;
  return user.first_name[0] + ". " + user.last_name;
});

Handlebars.registerHelper('full_name', function (user) {
  user = user || this;
  return user.first_name + " " + user.last_name;
});

Handlebars.registerHelper('ms', function (time) {
  return time ? _.date(time) : '';
});

Handlebars.registerHelper('date', function (time) {
  if(!time) { return; }
  var date = new Date(Date.parse(time));
  return date && date.strftime("%b %d");
});

Handlebars.registerHelper('time_ago', function (time) {
  return time ? _.date(Date.parse(time)).fromNow() : '';
});

Handlebars.registerHelper('equal', function (a, b, truthy, falsy) {
  truthy = typeof truthy === 'undefined' ? true: truthy;
  falsy = typeof falsy === 'undefined' ? false: falsy;
  return a === b ? truthy : falsy;
});

Handlebars.registerHelper('foreach', function (context, fn, inverse) {
  if (!_.isEmpty(context)) {
    return _.reduce(context, function (memo, value, key) {
      memo += fn({key: key, value: value});
      return memo;
    }, '');
  } else {
    return inverse(this);
  }
});

Handlebars.registerHelper('status_name', function () {
  return $w('new open hold resolved rejected')[this.status];
});

Handlebars.registerHelper('status_text', function () {
  if (this.status === 1 && this.assigned) {
    return this.assigned.user.first_name + " " + this.assigned.user.last_name[0];
  } else {
    return $w('new open hold resolved rejected')[this.status];
  }
});

// Render status transitions in comments
Handlebars.registerHelper('status_transition', function () {
  var status = $w('new open hold resolved rejected')
    .collect(function (s) {
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
Handlebars.registerPartial("task", Templates.partials.task);
