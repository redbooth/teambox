// Helper functions, mostly taken from jQuery
// MIT License - http://jquery.org/license

JUtils = module.exports = {};

JUtils.isFunction = function( obj ) {
	return toString.call(obj) === "[object Function]";
};

JUtils.isArray = function( obj ) {
	return toString.call(obj) === "[object Array]";
};

JUtils.isPlainObject = function( obj ) {
	// Must be an Object.
	// Because of IE, we also have to check the presence of the constructor property.
	// Make sure that DOM nodes and window objects don't pass through, as well
	if ( !obj || toString.call(obj) !== "[object Object]" || obj.nodeType || obj.setInterval ) {
		return false;
	}
	
	// Not own constructor property must be Object
	if ( obj.constructor
		&& !hasOwnProperty.call(obj, "constructor")
		&& !hasOwnProperty.call(obj.constructor.prototype, "isPrototypeOf") ) {
		return false;
	}
	
	// Own properties are enumerated firstly, so to speed up,
	// if last one is own, then all properties are own.

	var key;
	for ( key in obj ) {}
	
	return key === undefined || hasOwnProperty.call( obj, key );
};

JUtils.export = function() {
	// copy reference to target object
	var target = arguments[0] || {}, i = 1, length = arguments.length, deep = false, options, name, src, copy;

	// Handle a deep copy situation
	if ( typeof target === "boolean" ) {
		deep = target;
		target = arguments[1] || {};
		// skip the boolean and the target
		i = 2;
	}

	// Handle case when target is a string or something (possible in deep copy)
	if ( typeof target !== "object" && !JUtils.isFunction(target) ) {
		target = {};
	}

	for ( ; i < length; i++ ) {
		// Only deal with non-null/undefined values
		if ( (options = arguments[ i ]) != null ) {
			// Extend the base object
			for ( name in options ) {
				src = target[ name ];
				copy = options[ name ];

				// Prevent never-ending loop
				if ( target === copy ) {
					continue;
				}

				// Recurse if we're merging object literal values or arrays
				if ( deep && copy && ( JUtils.isPlainObject(copy) || JUtils.isArray(copy) ) ) {
					var clone = src && ( JUtils.isPlainObject(src) || JUtils.isArray(src) ) ? src
						: JUtils.isArray(copy) ? [] : {};

					// Never move original objects, clone them
					target[ name ] = JUtils.extend( deep, clone, copy );

				// Don't bring in undefined values
				} else if ( copy !== undefined ) {
					target[ name ] = copy;
				}
			}
		}
	}

	// Return the modified object
	return target;
};

JUtils.merge = function( first, second ) {
	var i = first.length, j = 0;

	if ( typeof second.length === "number" ) {
		for ( var l = second.length; j < l; j++ ) {
			first[ i++ ] = second[ j ];
		}
	} else {
		while ( second[j] !== undefined ) {
			first[ i++ ] = second[ j++ ];
		}
	}

	first.length = i;

	return first;
};

JUtils.grep = function( elems, callback, inv ) {
	var ret = [];

	// Go through the array, only saving the items
	// that pass the validator function
	for ( var i = 0, length = elems.length; i < length; i++ ) {
		if ( !inv !== !callback( elems[ i ], i ) ) {
			ret.push( elems[ i ] );
		}
	}

	return ret;
},

// arg is for internal usage only
JUtils.map = function( elems, callback, arg ) {
	var ret = [], value;

	// Go through the array, translating each of the items to their
	// new value (or values).
	for ( var i = 0, length = elems.length; i < length; i++ ) {
		value = callback( elems[ i ], i, arg );

		if ( value != null ) {
			ret[ ret.length ] = value;
		}
	}

	return ret.concat.apply( [], ret );
};

var push = Array.prototype.push;

JUtils.makeArray = function(array, results){
	var ret = results || [];

	if ( array != null ) {
		if ( array.length == null || typeof array === "string" || JUtils.isFunction(array) ) {
			push.call( ret, array );
		} else {
			JUtils.merge( ret, array );
		}
	}

	return ret;
};