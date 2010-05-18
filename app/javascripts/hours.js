var Hours = {
	init: function(start_date) {
		this.hours = [];
		this.start_date = start_date;
		this.weekends = [0,6];
		
		this.userMap = {};
		this.taskMap = {};
		this.projectMap = {};
		this.showWeekends = false;
		
		this.l_hours = 'hrs';
		
		this.filters = {
			'user': null,
			'task': null,
			'project': null
		};
		
		this.currentReport = 'user';
		
		// Link in filter checkboxes
		$$('#user_filters input').each(function(e){
			e.observe('click', Hours.userFilterHandler);
		});
		$$('#task_filters input').each(function(e){
			e.observe('click', Hours.taskFilterHandler);
		});
		$$('#project_filters input').each(function(e){
			e.observe('click', Hours.projectFilterHandler);
		});
		
		this.setProjectFilter(0, true);
		this.setUserFilter(0, true);
		this.setTaskFilter(0, true);
	},
	
	clearAll: function(selector, enabled) {
		$$(selector).each(function(e){
			e.checked = false;
			e.disabled = !enabled;
		});
	},
	
	setProjectFilter: function(id, enabled) {
		if (id == 0)
		{
			// All projects
			if (enabled)
			{
				this.clearAll('#project_filters .filter input', false);
				this.filters.project = null;
			}
			else
			{
				this.clearAll('#project_filters .filter input', true);
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
			// All projects
			if (enabled)
			{
				Hours.clearAll('#user_filters .filter input', false);
				Hours.filters.user = null;
			}
			else
			{
				Hours.clearAll('#user_filters .filter input', true);
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
	
	setTaskFilter: function(id, enabled) {
		if (id == 0)
		{
			// All projects
			if (enabled)
			{
				Hours.clearAll('#task_filters .filter input', false);
				Hours.filters.task = null;
			}
			else
			{
				Hours.clearAll('#task_filters .filter input', true);
				Hours.filters.task = [];
			}
		}
		else
		{
			if (enabled)
				Hours.filters.task.push(id);
			else
				Hours.filters.task = Hours.filters.task.without(id);
		}
	},
	
	projectFilterHandler: function(evt) {
		var el = $(this);
		var id = parseInt(el.readAttribute('value'));
		
		Hours.setProjectFilter(id, el.checked);
		Hours.update();
		return true;
	},
	
	userFilterHandler: function(evt) {
		var el = $(this);
		var id = parseInt(el.readAttribute('value'));
		
		Hours.setUserFilter(id, el.checked);
		Hours.update();
		return true;
	},
	
	taskFilterHandler: function(evt) {
		var el = $(this);
		var id = parseInt(el.readAttribute('value'));
		
		Hours.setTaskFilter(id, el.checked);
		Hours.update();
		return true;
	},
	
	addHour: function(comment) {
		var record = {
			id: comment.id,
			date: new Date(comment.date[0], comment.date[1], comment.date[2],0,0,0,0),
			week: comment.week,
			project_id: comment.project_id,
			user_id: comment.user_id,
			task_id: comment.task_id,
			hours: comment.hours
		};
		
		var d = record.date;
		record.key = d.getFullYear() + '-' + d.getMonth() + '-' + d.getDate();
		this.hours.push(record);
	},
	
	addHours: function(comments) {
		comments.each(function(comment){
			var record = {
				id: comment.id,
				date: new Date(comment.date[0], comment.date[1], comment.date[2],0,0,0,0),
				week: comment.week,
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
				var value = list[c.user_id];
				var id = c[field];
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
				var code = "<p class=\"hours\">" + map[key] + '<br/>' + values[key].toFixed(2) + ' ' + this.l_hours + "</p>";
				$('week_' + i).insert({top:code});
			}
		}
		
		for (var key in totalSum) {
			var code = "<p class=\"hours\">" + map[key] + '<br/>' + totalSum[key].toFixed(2) + ' ' + this.l_hours + "</p>";
			$('hour_total').insert({top:code});
		}
		$('total_sum').innerHTML = weekTotal.toFixed(2) + ' ' + this.l_hours;
		
		// Insert comments into the calendar
		this.insertCommentBlocks(comments, function(v, list, block){
			list.keys().each(function(key){
				var code = "<p class=\"hours\">" +  map[key] + "<br/>" + list.get(key).toFixed(2) + ' ' + Hours.l_hours + " </p>";
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
		var taskFilters = this.filters.task;
		
		return this.mapComments(this.hours, function(c) {
			if (!Hours.applyFilter(c,
				                  projectFilters,
				                  userFilters,
				                  taskFilters))
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
	
	applyFilter: function(hour, projectFilters, userFilters, taskFilters){
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
		
		if (taskFilters != null) {
			// Task?
			if (taskFilters.indexOf(hour.task_id) == -1)
				return false;
		}
		
		return true;
	}
};
