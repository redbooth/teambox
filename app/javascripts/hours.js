var Hours = {
  init: function(start_date) {
    this.hours = [];
    this.start_date = start_date;
    this.weekends = [0,6];
    
    this.userMap = {};
    this.taskMap = {};
    this.projectMap = {};
    this.organizationMap = {};
    this.showWeekends = false;
    
    this.filters = {
      'user': null,
      'project': null,
      'organization': null,
    };
    
    this.currentReport = 'user';
    
    // Link in filter checkboxes
    document.on('change', '#user_filters select', Hours.userFilterHandler);
    document.on('change', '#project_filters select', Hours.projectFilterHandler);
    document.on('change', '#organization_filters select', Hours.organizationFilterHandler);


    this.setProjectFilter(0, true);
    this.setUserFilter(0, true);
    this.setOrganizationFilter(0, true);
  },
  
  clearAll: function(selector, enabled) {
    $$(selector).each(function(e){
      e.checked = false;
      e.disabled = !enabled;
    });
  },

  setOrganizationFilter: function(id, enabled) {
    if (id == 0)
    {
      // All organizations
      if (enabled)
      {
        this.filters.organization = null;
      }
      else
      {
        this.filters.organization = [];
      }
    }
    else
    {
      if (enabled)
        this.filters.organization.push(id);
      else
        this.filters.organization = Hours.filters.organization.without(id);
    }
  },


  setProjectFilter: function(id, enabled) {
    if (id == 0)
    {
      // All projects
      if (enabled)
      {
        this.filters.project = null;
      }
      else
      {
        this.filters.project = [];
      }
    }
    else
    {
      if (enabled)
        this.filters.project.push(id);
      else
        this.filters.project = Hours.filters.project.without(id);
    }
  },
  
  setUserFilter: function(id, enabled) {
    if (id == 0)
    {
      // All users
      if (enabled)
      {
        Hours.filters.user = null;
      }
      else
      {
        Hours.filters.user = [];
      }
    }
    else
    {
      if (enabled)
        Hours.filters.user.push(id);
      else
        Hours.filters.user = Hours.filters.user.without(id);
    }
  },

  organizationFilterHandler: function(evt, el) {
    var value = el.getValue();

    Hours.setOrganizationFilter(0, false);
    Hours.setOrganizationFilter(parseInt(value), true);

    Hours.update();
    return true;
  },

  projectFilterHandler: function(evt, el) {
    var value = el.getValue();
    
    Hours.setProjectFilter(0, false);
    Hours.setProjectFilter(parseInt(value), true);
    
    Hours.update();
    return true;
  },
  
  userFilterHandler: function(evt, el) {
    var value = el.getValue();
    
    Hours.setUserFilter(0, false);
    Hours.setUserFilter(parseInt(value), true);
    
    Hours.update();
    return true;
  },
  
  addHours: function(comments) {
    comments.each(function(comment){
      var record = {
        id: comment.id,
        date: new Date(comment.date[0], comment.date[1], comment.date[2],0,0,0,0),
        week: comment.week,
        organization_id: comment.organization_id,
        project_id: comment.project_id,
        user_id: comment.user_id,
        task_id: comment.task_id,
        hours: comment.hours
      };
      
      var d = record.date;
      record.key = d.getFullYear() + '-' + d.getMonth() + '-' + d.getDate();
      Hours.hours.push(record);  
    });
  },
  
  setReport: function(report) {
    this.currentReport = report;
    this.update();
  },
  
  update: function() {
    // Run report
    this['report_' + this.currentReport]();
  },
  
  insertCommentBlocks: function(comments, func){
    comments.keys().each(function(key){
      var v = comments.get(key);
      var date = v.date;
      if (date) {
        var calBlock = $("day_" + (date.getMonth()+1) + "_" + date.getDate());
        func(v, v.list, calBlock);
      }
    });
  },
  
  clearCommentBlocks: function(){
    $$('p.hours').each(function(e){e.remove();});
  },
  
  sumByHours: function(field, map) {
    var comments = this.getFilteredComments();
    var weekSum = [{},{},{},{},{},{}];
    var totalSum = {};
    var weekTotal = 0;
    this.showWeekends = false;
    
    // Hide all comments
    $$('div.comment').each(function(e){e.hide();});
    
    comments = this.reduceComments(comments, function(key, values){
      var item = {};
      if (values.length > 0)
        item.date = values[0].date;
      else
        item.date = null;
      
      var list = {};
      values.each(function(c){
        // Total day
        var id = c[field];
        var value = list[id];
        if (value == null || value == undefined)
          list[id] = c.hours;
        else 
          list[id] += c.hours;
          
        $('comment_' + c.id).show();
        
        // Weekday?
        if (!Hours.showWeekends)
        {
          var day = c.date.getDay();
          if (day == 0 || day == 6)
            Hours.showWeekends = true;
        }
        
        // Total week
        var week = Math.floor((c.date - Hours.start_date) / (86400000 * 7));
        var sum = weekSum[week][id];
        if (sum == null || sum == undefined)
          weekSum[week][id] = c.hours;
        else
          weekSum[week][id] += c.hours;
        
        // Total month
        sum = totalSum[id];
        if (sum == null || sum == undefined)
          totalSum[id] = c.hours;
        else
          totalSum[id] += c.hours;
        
        weekTotal += c.hours;
      });
      
      item.list = $H(list);
      return item;
    });
    
    this.clearCommentBlocks();
    
    for (var i=0; i<5; i++) {
      var values = weekSum[i];
      for (var key in values) {
        var code = "<p class=\"hours\">" + map[key] + '<br/>' + values[key].friendlyHours(2) + "</p>";
        $('week_' + i).insert({top:code});
      }
    }
    
    for (var key in totalSum) {
      var code = "<p class=\"hours\">" + map[key] + '<br/>' + totalSum[key].friendlyHours(2) + "</p>";
      $('hour_total').insert({top:code});
    }
    $('total_sum').innerHTML = weekTotal.friendlyHours();
    
    // Insert comments into the calendar
    this.insertCommentBlocks(comments, function(v, list, block){
      list.keys().each(function(key){
        var code = "<p class=\"hours\">" +  map[key] + "<br/>" + list.get(key).friendlyHours(2) + " </p>";
        block.insert({bottom:code});
      });
    });
    
    // Toggle weekends
    if (this.showWeekends) {
      $$('.cal_wd' + this.weekends[0] + ', .cal_wd' + this.weekends[1]).each(function(e) {e.show();});
      $('calendar').removeClassName('calendar5');
    } else {
        $$('.cal_wd' + this.weekends[0] + ', .cal_wd' + this.weekends[1]).each(function(e) {e.hide();});
      $('calendar').addClassName('calendar5');
    }
    
    return comments;
  },
  
  report_user: function(){
    return this.sumByHours('user_id', this.userMap);
  },
  
  report_task: function(){
    return this.sumByHours('task_id', this.taskMap);
  },
  
  report_project: function(){
    return this.sumByHours('project_id', this.projectMap);
  },
  
  getFilteredComments: function(){
    var projectFilters = this.filters.project;
    var userFilters = this.filters.user;
    var organizationFilters = this.filters.organization;

    return this.mapComments(this.hours, function(c) {
      if (!Hours.applyFilter(c,
                          projectFilters,
                          userFilters,
                          organizationFilters))
        return null;
      
      return {key:c.key, value:c};
    });
  },
  
  mapComments: function(comments, func){
    var set = {};
    comments.each(function(c){
      var res = func(c);
      if (res == null)
        return;
      
      var key = res.key;
      var value = res.value;
      
      var sv = set[key];
      if (sv == null || sv == undefined)
        set[key] = [value];
      else
        sv.push(value);
    });
    
    return $H(set);
  },
  
  reduceComments: function(comments, func){
    var res = $H();
    comments.keys().each(function(key){
      var values = comments.get(key);
      res.set(key, func(key, values));
    });
    return res;
  },
  
  applyFilter: function(hour, projectFilters, userFilters, organizationFilters){
    if (organizationFilters != null) {
      // Organization?
      if (organizationFilters.indexOf(hour.organization_id) == -1)
        return false;
    }

    if (projectFilters != null) {
      // Project?
      if (projectFilters.indexOf(hour.project_id) == -1)
        return false;
    }
    
    if (userFilters != null) {
      // User?
      if (userFilters.indexOf(hour.user_id) == -1)
        return false;
    }
    
    return true;
  }
};

Number.prototype.friendlyHours = function() {
  if (this <= 0)
    return 0;
  var out = this.floor() + 'h', minutes = ((this % 1) * 60).round()
  if (minutes) out += ' ' + minutes + 'm'
  return out
};
