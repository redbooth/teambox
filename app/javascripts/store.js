Store = {
  set: function(key, data) {
    localStorage[key] = JSON.stringify(data)
    return data
  },
  get: function(key) {
    return localStorage[key] ? JSON.parse(localStorage[key]) : null
  },
  clear: function() {
    localStorage.clear()
  }
}
