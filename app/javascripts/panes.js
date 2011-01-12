// Creates JS panes that replace #content, but save its contents so the
// pane can be closed and go back to the previous state without page loads

Pane = {
  save: function() {
    Pane.previousContent = $('content').innerHTML;
    $('content').innerHTML = "";
  },
  clear: function() {
    Pane.previousContent = undefined;
    Pane.previousURL = undefined;
  },
  replace: function(content, url) {
    $('content').update(content);
    if (url) {
      Pane.previousURL = window.location.pathname;
      pushHistoryState(url);
    }
  },
  saveAndReplace: function(content) {
    Pane.save();
    Pane.replace(content);
  },
  retrieve: function() {
    if(Pane.previousContent) {
      $('content').update(Pane.previousContent);
      if(Pane.previousURL) {
        pushHistoryState(Pane.previousURL);
      }
      Pane.clear();
    }
  }
};


document.on('click', 'a.closePane', function(e, el) {
  e.preventDefault();
  Pane.retrieve();
});

