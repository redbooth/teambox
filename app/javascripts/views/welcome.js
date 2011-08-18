(function () {
  var WelcomeView = { className: 'projects'
                    , template: Teambox.modules.ViewCompiler('welcome.intro')
                    };

  WelcomeView.events = {
    'click .welcome_navigation a.prev' : 'previousPage'
  , 'click .welcome_navigation a.next' : 'nextPage'
  };

  // The view Welcome.intro contains many .section divs.
  // Navigating will hide all sections except the active one
  // and update the position counter in the navigation bar.

  WelcomeView.render = function () {
    var html = this.template();
    this.el.update(html);
    this.el.select('.section').invoke('hide');
    this.currentPage = 0;
    this.totalPages = this.el.select('.section').length;
    this.updateNavigation();
    return this;
  };

  WelcomeView.previousPage = function() {
    this.currentPage -= 1;
    if (this.currentPage < 0) {
      this.currentPage = 0;
    }
    this.updateNavigation();
  };

  WelcomeView.nextPage = function() {
    this.currentPage += 1;
    if (this.currentPage > this.totalPages - 1) {
      this.currentPage = this.totalPages - 1;
    }
    this.updateNavigation();
  };

  WelcomeView.updateNavigation = function() {
    this.el.down('span').update("Page "+(this.currentPage+1)+" / "+this.totalPages);
    this.el.select('.section').invoke('hide');
    this.el.select('.section')[this.currentPage].show();
  };

  // exports
  Teambox.Views.Welcome = Backbone.View.extend(WelcomeView);
}());

