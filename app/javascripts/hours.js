var Hours = {
	init: function(start_date) {
		this.hours = [];
		this.filtered_set = [];
		this.start_date = start_date;
		
		// i.e. week_row = (comment.date - this.start_date) / (day*7)
	},
	
	addHour: function(comment) {
		var record = {
			id: comment.id,
			date: comment.date,
			week: comment.week,
			user_id: comment.userid,
			task_id: comment.task_id,
			hours: comment.hours
		};
		this.hours.push(record);
	},
	
	addHours: function(comments) {
		comments.forEach(function(comment){
			var record = {
				id: comment.id,
				date: comment.date,
				week: comment.week,
				user_id: comment.userid,
				task_id: comment.task_id,
				hours: comment.hours
			};
			
			Hours.hours.push(record);	
		});
	},
	
	filterByFunc: function(func) {
		this.filtered_set = this.hours.select(func);
	},
	
	clearSet: function() {
		var len = this.filtered_set.length;
		while (len-- != 0) {
			this.filtered_set.pop();
		}
	},
	
	clear: function() {
		var len = this.hours.length;
		while (len-- != 0) {
			this.hours.pop();
		}
	}
};
