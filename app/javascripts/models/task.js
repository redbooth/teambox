(function () {

  var _one_day = 1000 * 60 * 60 * 24
    , Task = {}
    , TaskStatic = {};

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

  Task.url = function () {
    return "/api/1/tasks/" + this.get('id');
  };

  // static
  TaskStatic.filters = {
    due_date: [ 'overdue'
              , 'due_today'
              , 'due_tomorrow'
              , 'due_week'
              , 'due_2weeks'
              , 'due_3weeks'
              , 'due_month'
              , 'unassigned_date' ]
  , assigned: ['mine', 'assigned', 'unassigned']
  , status: ['new', 'open', 'hold', 'resolved', 'rejected']
  }

  // exports
  Teambox.Models.Task = Backbone.Model.extend(Task, TaskStatic);

}());
