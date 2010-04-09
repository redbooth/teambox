;(function(){
  var element
  
  var Facebox = {
    open: function(html, classname, extra) {
      classname || (classname = 'html')
      // element.down('.facebox-wrapper').setStyle({ 'margin-top': window.scrollY + 100 + 'px' })
      element.down('.facebox-wrapper').className = 'facebox-wrapper ' + classname
      var content = element.down('.facebox-content').update(html)
      element.down('.facebox-extra .description').update(extra)
      element.setStyle({ display: 'block' })
      if (classname == 'loading') content.fire('facebox:loading')
      else content.fire('facebox:opened', { type: classname })
    },
    openImage: function(src, alt) {
      this.open('Loading image ...', 'loading')
      var image = new Image()
      image.onload = function() {
        this.open('<img src="' + src + '">', 'image', alt)
        console.log({ width:image.width, height:image.height })
        element.down('.facebox-wrapper').setStyle({ width:image.width+'px' })
      }.bind(this)
      image.src = src
    },
    openUrl: function(url, extra) {
      this.open('Loading ...', 'loading')
      new Ajax.Request(url, {
        method: 'get',
        onSuccess: function(response) {
          this.open(response.responseText)
        }.bind(this),
        onFailure: function(response) {
          this.open('There has been an error.', 'error')
        }.bind(this)
      })
    }
  }
  
  var close = function() {
    if (element.getStyle('display') == 'block') {
      element.hide().fire('facebox:closed')
    }
  }
  var setElement = function(fn) {
    $(document.body).insert({ bottom: "<div id='facebox' style='display: none'>\
      <div class='facebox-wrapper html'>\
        <div class='facebox-container'>\
          <div class='facebox-content'></div>\
          <div class='facebox-extra'><p class='description'></p><a class='close' href='#close'>close</a></div>\
        </div></div></div>"
      })
    element = $('facebox')
    if (element && fn) fn(element)
  }

  document.on('dom:loaded', function() {
    setElement(function(box) {
      box.on('click', function(e) {
        if (e.findElement('.facebox-extra .close') || !e.findElement('.facebox-wrapper')) {
          e.preventDefault()
          close()
        }
      })
      document.on('keyup', function(e) {
        if (e.keyCode == Event.KEY_ESC) close()
      })
      document.on('click', '*[rel=facebox]', function(e) {
        var el = e.element(),
            href = el.readAttribute('href'),
            extra = el.readAttribute('title')
        
        e.preventDefault()
        
        if (/^#(.+)/.test(href)) {
          var source = $(RegExp.$1)
          if (source) Facebox.open(source.innerHTML, 'html', extra)
        }
        else if (/\.(png|jpe?g|gif)$/i.test(href)) {
          Facebox.openImage(href, extra)
        }
        else {
          Facebox.openUrl(href, extra)
        }
      })
    })
  })
  
  Prototype.Facebox = Facebox
})()
