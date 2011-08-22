(function () {

  var ChatController = { routes: { '!/chat' : 'room_show' } }
    , Views = Teambox.Views
    , Controllers = Teambox.Controllers
    , views = Teambox.views;

  ChatController.room_show = function () {
    Views.Sidebar.highlightSidebar('chat_link');
    $('content').update(
      "<iframe src='https://teambox.talkerapp.com/rooms/819' style='width:  100%; height: 99%; border: 0; margin:  0; padding: 0;'></iframe>"
    );
  };

  // exports
  Teambox.Controllers.ChatController = Teambox.Controllers.BaseController.extend(ChatController);

}());
