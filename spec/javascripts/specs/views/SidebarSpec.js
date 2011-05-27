/*globals setFixtures, describe, beforeEach, expect, it, jasmine, sinon*/
describe("views/sidebar", function () {

  var SidebarView = Teambox.Views.Sidebar
    , sidebar;

  beforeEach(function () {
    setFixtures('<div id="sidebar">'
              + '<div class="nav_links">'
              + '<div class="el"><a href="/zemba">Zemba</a></div>'
              + '<div class="el"><a href="/zemba/flow">Flow</a></div>'
              + '<div class="el"><a href="/mega">Mega</a></div>'
              + '<div class="el"><a href="/trasca">Trasca</a></div>'
              + '<div class="el"><a href="/haskell/is/cool">Haskell</a></div>'
              + '</div>'
              + '</div>');
  });

  it('`detectSelectedSection` should match navigation link with the url', function () {
    expect(SidebarView.detectSelectedSection('/zemba')).toEqual($$('.nav_links .el')[0]);
    expect(SidebarView.detectSelectedSection('/zemba/flow')).toEqual($$('.nav_links .el')[1]);
    expect(SidebarView.detectSelectedSection('/trasca/fleirous')).toEqual($$('.nav_links .el')[3]);
    expect(SidebarView.detectSelectedSection('/lady-gaga')).toBeFalsy();
  });

});
