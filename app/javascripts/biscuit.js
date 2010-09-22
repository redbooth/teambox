(function() {

	var Cookie = Class.create(Hash, {
		set: function(key, value, params) {
		
		
			if (key == undefined) new Error('No key');
			if (value == undefined) new Error('No value');
			to_set =  key + "=" + value;
			
			if (params != undefined) {
				if ( params['expires'] != undefined && params['max_age'] == undefined) {
					//calculate max_age based off now
					var nowish = new Date();
					var thenish = params['expires'];
					params['max_age'] = Math.round((thenish.getTime() - nowish.getTime()) / 1000.0);
					}
				if (params['max_age'] != undefined && !isNaN(params['max_age']) ) {
					to_set += ";max-age=" + params['max_age'];
					}
				if (params['path'] != undefined) {
					to_set += ";path=" + params['path'];
					}
				if (params['domain'] != undefined) {
					to_set += ";path=" + params['domain'];
					}
				if (params['secure'] != undefined) {
					to_set += ";secure";
					}
				}
			document.cookie = to_set;
			return this._object[key] = value;
			},
		
		unset:  function(key) {
			var value = this._object[key];
			to_set =  key + "=" + value + ";max-age=0";
			delete this._object[key];
			document.cookie = to_set;
			return value;
			},
		
		get: function(key) {
			if (this._object[key] !== Object.prototype[key])
			return decodeURIComponent(this._object[key]);
			},
			
		inspect: function () {
			return '#<Cookie:{' + this.map(function(pair) {
				return pair.map(Object.inspect).join(': ');
				}).join(', ') + '}>';
			}


			});

	function cookies() {
		cook = new Cookie;
		document.cookie.split("; ").invoke('split', '=', 2).each(function(val) { cook.set(val[0],val[1]); });
		return cook;
		}

	Object.extend(document, {
		cookies: cookies
		});

})();