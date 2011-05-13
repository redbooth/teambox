JavascriptReloading = {

  reload: function() {
    $$('script[src]').select(function(s) {
      return s.readAttribute('src').match("/sprockets.js");
    }).invoke('remove');

    var script = new Element('script', {src:'/sprockets.js?' + (+new Date())});
    script.onload = this.onreload;
    $$('head').first().appendChild(script);
    Teambox.modules.Loader.init();
  },

  onreload: function() {
    console.log('sprockets reloaded');
    $app = Teambox.application = new Teambox.Controllers.AppController();
  },

  insertButton: function() {
    var e = new Element('a', {'class': 'button', id: 'reload_javascript', href: '#', style: 'position:absolute;left: 500px;top:10px;'}).insert('Reload JS');
    $$('body').first().insert({top: e});

    e.on('click', function(ev,el) {
      ev.stop();
      console.log('reloading sprockets...');
      JavascriptReloading.reload();
    });
  }

};

document.on('dom:loaded', JavascriptReloading.insertButton);

