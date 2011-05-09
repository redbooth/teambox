
String.prototype.assertEquals = function(given,expected) {
  var text;
  if (given == expected) {
    text = "Test passed";
  } else {
    text = "<span style='color: red'>Test FAILED:</span> "+this+"<br/>"+
           "Expected: "+expected.escapeHTML()+"<br/>"+
           "Got: &nbsp;&nbsp;&nbsp;&nbsp; "+ given.escapeHTML();
  }
  text = "<p>"+text+"</p>";
  $('testResults').insert({ bottom: text });
}

String.prototype.assertEqualsArray = function(given,expected) {
  var text;
  if (given.inspect() == expected.inspect()) {
    text = "Test passed";
  } else {
    text = "<span style='color: red'>Test FAILED:</span> "+this+"<br/>"+
           "Expected: "+expected.escapeHTML()+"<br/>"+
           "Got: &nbsp;&nbsp;&nbsp;&nbsp; "+ given.escapeHTML();
  }
  text = "<p>"+text+"</p>";
  $('testResults').insert({ bottom: text });
}