document.on("click", ".el a.chat", function(e,el) {
  e.stop();
  $$('.content_wrap')[0].innerHTML =
    "<iframe src='https://teambox.talkerapp.com/rooms/819' style='width:  100%; height: 99%; border: 0; margin:  0; padding: 0;'></iframe>";
});
