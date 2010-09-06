// * Stopwatch class {{{
Stopwatch = function(listener, resolution) {
	this.startTime = 0;
	this.stopTime = 0;
	this.totalElapsed = 0; // * elapsed number of ms in total
	this.started = false;
	this.listener = (listener != undefined ? listener : null); // * function to receive onTick events
	this.tickResolution = (resolution != undefined ? resolution : 500); // * how long between each tick in milliseconds
	this.tickInterval = null;
	
	// * pretty static vars
	this.onehour = 1000 * 60 * 60;
	this.onemin  = 1000 * 60;
	this.onesec  = 1000;
}
Stopwatch.prototype.start = function() {
	var delegate = function(that, method) { return function() { return method.call(that) } };
	if(!this.started) {
		this.startTime = new Date().getTime();
		this.stopTime = 0;
		this.started = true;
		this.tickInterval = setInterval(delegate(this, this.onTick), this.tickResolution);
	}
}
Stopwatch.prototype.stop = function() {
	if(this.started) {
		this.stopTime = new Date().getTime();
		this.started = false;
		var elapsed = this.stopTime - this.startTime;
		this.totalElapsed += elapsed;
		if(this.tickInterval != null)
			clearInterval(this.tickInterval);
	}
	return this.getElapsed();
}
Stopwatch.prototype.reset = function() {
	this.totalElapsed = 0;
	// * if watch is running, reset it to current time
	this.startTime = new Date().getTime();
	this.stopTime = this.startTime;
}
Stopwatch.prototype.restart = function() {
	this.stop();
	this.reset();
	this.start();
}
Stopwatch.prototype.getElapsed = function() {
	// * if watch is stopped, use that date, else use now
	var elapsed = 0;
	if(this.started)
		elapsed = new Date().getTime() - this.startTime;
	elapsed += this.totalElapsed;
	
	var hours = parseInt(elapsed / this.onehour);
	elapsed %= this.onehour;
	var mins = parseInt(elapsed / this.onemin);
	elapsed %= this.onemin;
	var secs = parseInt(elapsed / this.onesec);
	var ms = elapsed % this.onesec;
	
	return {
		hours: hours,
		minutes: mins,
		seconds: secs,
		milliseconds: ms
	};
}
Stopwatch.prototype.setElapsed = function(hours, mins, secs) {
	this.reset();
	this.totalElapsed = 0;
	this.totalElapsed += hours * this.onehour;
	this.totalElapsed += mins  * this.onemin;
	this.totalElapsed += secs  * this.onesec;
	this.totalElapsed = Math.max(this.totalElapsed, 0); // * No negative numbers
}
Stopwatch.prototype.toString = function() {
	var zpad = function(no, digits) {
		no = no.toString();
		while(no.length < digits)
			no = '0' + no;
		return no;
	}
	var e = this.getElapsed();
	return zpad(e.hours,2) + ":" + zpad(e.minutes,2) + ":" + zpad(e.seconds,2);
}
Stopwatch.prototype.setListener = function(listener) {
	this.listener = listener;
}
// * triggered every <resolution> ms
Stopwatch.prototype.onTick = function() {
	if(this.listener != null) {
		this.listener(this);
	}
}
// }}}
