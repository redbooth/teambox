(function () {

  /* gets the value of a param on the url
   *
   * @param {String} name
   * @return {String} value
   */
  function params(name, url) {
    var regex, results;

    url = url || window.location.href;
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    regex = new RegExp("[\\?&]" + name + "=([^&#]*)");
    results = regex.exec(url);

    return results === null ? null : results[1];
  };

  //exports
  Teambox.modules.params = params;

}());
