(function () {

  var _one_day = 1000 * 60 * 60 * 24
    , Task = {}
    , TaskStatic = {}
    , _status_names = ['new', 'open', 'hold', 'resolved', 'rejected'];

  /* Returns the class name
   *
   * @return {String}
   */
  Task.className = function () {
    return 'Task';
  };

  /* gets the status_name
   *
   * @return {String}
   */
  Task.statusName = function () {
    return _status_names[this.get('status')] || 'new';
  };

  /* is the task archived?
   *
   * @return {Boolean}
   */
  Task.isArchived = function () {
    return ['rejected', 'resolved'].indexOf(this.statusName()) !== -1;
  };

  /* is the task open?
   *
   * @return {Boolean}
   */
  Task.isOpen = function () {
    return this.statusName() === 'open';
  };

  /* get the overdue if a due date is provided
   *
   * @param {Integer} offset
   * @return {String} overdue
   */
  Task.overdue = function (offset) {
    if (this.get('due_on')) {
      var ms_difference = _.now().from(_.date(this.get('due_on'), "YYYY-MM-DD"), true, true);
      return Math.floor((ms_difference + (offset || 0)) / _one_day);
    } else {
      return null;
    }
  };

    /* is the task overdue?
     *
     * @return {Boolean} overdue?
     */
  Task.is_overdue = function () {
    return !this.get('archived?') && this.overdue() > 0;
  };

    /* is the task due for today?
     *
     * @return {Boolean} overdue today?
     */
  Task.is_due_today = function () {
    return this.overdue() === 0;
  };

    /* is the task due for tomorrow?
     *
     * @return {Boolean} overdue tomorrow?
     */
  Task.is_due_tomorrow = function () {
    return this.overdue() === -1;
  };

    /* is the task due in xxx?
     *
     * @return {Boolean} overdue in?
     */
  Task.is_due_in = function (time_end) {
    return this.get('due_on') && !this.is_overdue() && this.overdue(time_end) <= 0;
  };

  Task.publicUrl = function () {
    return '/projects/' + this.get('project_id') + '/tasks/' + this.get('id');
  };

  Task.url = function () {
    return "/api/1/tasks/" + this.get('id');
  };

  // static
  TaskStatic.status = {
    due_date: { overdue:         {order: 0, label: 'late tasks'}
              , due_today:       {order: 1, label: 'today'}
              , due_tomorrow:    {order: 2, label: 'tomorrow'}
              , due_week:        {order: 3, label: 'this week'}
              , due_2weeks:      {order: 4, label: 'next 2 weeks'}
              , due_3weeks:      {order: 5, label: 'next 3 weeks'}
              , due_month:       {order: 6, label: 'within 1 month'}
              , unassigned_date: {order: 7, label: 'no date assigned'}
              }
  , assigned: { mine:            {order: 0, label: 'mine'}
              , assigned:        {order: 1, label: 'assigned'}
              , unassigned:      {order: 2, label: 'unassigned'}
              }
  , status:   { 'new':             {order: 0, value: 0, label: 'new'}
              , open:              {order: 1, value: 1, label: 'open'}
              , hold:              {order: 2, value: 2, label: 'hold'}
              , resolved:          {order: 3, value: 3, label: 'resolved'}
              , rejected:          {order: 4, value: 4, label: 'rejected'}
              }
  }

  // exports
  Teambox.Models.Task = Teambox.Models.Base.extend(Task, TaskStatic);

}());

