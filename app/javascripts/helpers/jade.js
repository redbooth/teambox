(function () {
  var JADE = {};

  // expose the global namespace
  JADE.Teambox = Teambox;

  JADE.partial = function (path, locals) {
    return Teambox.modules.ViewCompiler(path)(locals);
  };

  JADE.short_name = function (user) {
    return user.first_name[0] + '. ' + user.last_name;
  };

  JADE.full_name = function (user) {
    return user.first_name + ' ' + user.last_name;
  };

  JADE.ms = function (time) {
    return time ? Date.parse(time) : '';
  };

  JADE.date = function (time) {
    if (!time) {
      return;
    }
    var date = new Date(Date.parse(time));
    return date && date.strftime("%b %d");
  };

  JADE.timeAgo = function (time) {
    return time ? new Date(Date.parse(time)).timeAgo() : '';
  };

  JADE.transition_due_on = function (due_on, previous_due_on) {
    var out = '';

    function taskDueOn(date) {
      date = _.date(Date.parse(date));

      if (date.fromNow(true, true) === 0) {
        return 'today';
      } else if (date.fromNow(true, true) === 1000 * 3600 * 24) {
        return 'tomorrow';
      } else if (date) {
        return date.format('MMM Do');
      }
    }

    function spanForDueDate(date) {
      return '<span class="assigned_date">' + taskDueOn(date) + '</span>';
    }

    if (due_on !== previous_due_on) {
      if (previous_due_on) {
        out += spanForDueDate(previous_due_on);
        out += '<span class="arr due_on_arr">&rarr;</span>';
      }
      out += spanForDueDate(due_on);
    }

    return out;
  };

  JADE.human_hours = function (hours) {
    if (!hours) {
      return '';
    }

    var minutes;
    hours = +hours.toFixed(2);

    if (hours > 0) {
      minutes = Math.round((hours % 1) * 60);

      if (minutes === 60) {
        hours++;
        minutes = 0;
      }

      if (minutes === 0) {
        return ~~hours + 'h';
      } else {
        return ~~hours + 'h ' + minutes + 'm';
      }
    }
  };

  JADE.status_name = function () {
    return $w('new open hold resolved rejected')[this.status];
  };

  JADE.status_text = function () {
    if (this.status === 1 && this.assigned) {
      return this.assigned.user.first_name + ' ' + this.assigned.user.last_name[0];
    } else {
      return $w('new open hold resolved rejected')[this.status];
    }
  };

  // Render status transitions in comments
  JADE.status_transition = function () {
    var status = $w('new open hold resolved rejected')
      .collect(function (s) {
        return '<span class="task_status task_status_' + s + '">' + s + '</span>';
      })
      , before = status[this.previous_status]
      , now = status[this.status];

    return [before, now].compact().join('<span class="arr status_arr"> &rarr; </span>');
  };

  JADE.project_url = function (project) {
    return '#!/projects/' + project.permalink;
  };

  JADE.comment_url = function (comment) {
    return comment.target.url();
  };

  JADE.conversation_url = function (conversation, project) {
    return '#!/projects/' + project.permalink + '/conversations/' + conversation.id;
  };

  JADE.task_url = function (task, project) {
    return '#!/projects/' + project.permalink + '/tasks/' + task.id;
  };

  JADE.google_docs_url = function (google_doc, project) {
    return '#!/projects/' + project.permalink + '/google_docs/' + google_doc.id;
  };

  JADE.task_list_url = function (task_list, project) {
    return '#!/projects/' + project.permalink + '/task_lists/' + task_list.id;
  };

  JADE.note_url = function (note, project) {
    return '#!/projects/' + project.permalink + '/pages/' + note.page_id;
  };

  JADE.page_url = function (page, project) {
    return '#!/projects/' + project.permalink + '/pages/' + page.id;
  };

  JADE.user_url = function (user) {
    return '#!/users/' + user.username;
  };

  JADE.downloadUrl = function(id, filename, type) {
    return "/downloads/#{id}/#{type}/#{filename}".interpolate({id: id, type: type, filename: escape(filename)});
  };


  // exports
  Teambox.helpers.jade = JADE;
}());
