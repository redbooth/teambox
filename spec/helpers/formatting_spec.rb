require 'spec_helper'

describe HtmlFormatting, 'Should apply our special Markdown' do
  
  subject do
    user = Factory.create(:user)
    comment = Comment.new :body => description
    comment.user = user
    comment.save!
    comment.body_html.strip
  end

  it "Did you know trololo? http://youtu.be/iwGFalTRHDA It's awesome." do
    should == "<p>Did you know trololo? <iframe class=\"youtube-player\" type=\"text/html\" width=\"480\" height=\"385\" src=\"http://www.youtube.com/embed/iwGFalTRHDA\" frameborder=\"0\"></iframe> It's awesome.</p>"
  end

  it "Did you know [trololo](http://youtube.com/watch?v=iwGFalTRHDA)? It's awesome." do
    should == "<p>Did you know <a href=\"http://youtube.com/watch?v=iwGFalTRHDA\">trololo</a>? It's awesome.</p>"
  end

  it "Did you know trololo? http://youtube.com/watch?v=iwGFalTRHDA It's awesome." do
    should == "<p>Did you know trololo? <iframe class=\"youtube-player\" type=\"text/html\" width=\"480\" height=\"385\" src=\"http://www.youtube.com/embed/iwGFalTRHDA\" frameborder=\"0\"></iframe> It's awesome.</p>"
  end

  it "Random video http://www.youtube.com/watch?v=JDRabp-iGtg&feature=rec-LGOUT-exp_fresh+div-1r-5-HM" do
    should == "<p>Random video <iframe class=\"youtube-player\" type=\"text/html\" width=\"480\" height=\"385\" src=\"http://www.youtube.com/embed/JDRabp-iGtg\" frameborder=\"0\"></iframe></p>"
  end

  it "Did you know trololo? http://www.youtube.com/watch?v=iwGFalTRHDA&feature=related It's awesome." do
    should == "<p>Did you know trololo? <iframe class=\"youtube-player\" type=\"text/html\" width=\"480\" height=\"385\" src=\"http://www.youtube.com/embed/iwGFalTRHDA\" frameborder=\"0\"></iframe> It's awesome.</p>"
  end

  it "This is a table. <table><tr><th>Foo</th></tr><tr><td>Bar</td></tr></table> This is another regular paragraph." do
    should == "<p>This is a table. <table><tr><th>Foo</th></tr><tr><td>Bar</td></tr></table> This is another regular paragraph.</p>"
  end

  it "should remove <div> block" do
    should == "<p>should remove  block</p>"
  end

  it "some **bold** text" do
    should == "<p>some <strong>bold</strong> text</p>"
  end
  
  it "some *italic* text" do
    should == "<p>some <em>italic</em> text</p>"
  end
  
  it "She used to mean:\n\n* So\n* much\n* to\n * me!" do
    should == "<p>She used to mean:</p>\n\n<ul>\n<li>So</li>\n<li>much</li>\n<li>to</li>\n<li>me!</li>\n</ul>"
  end

  it "she@couchsurfing.org used to mean so much to www.teambox.com" do
    should == "<p><a href=\"mailto:she@couchsurfing.org\">she@couchsurfing.org</a> used to mean so much to <a href=\"http://www.teambox.com\">www.teambox.com</a></p>"
  end

  it %(I loved that quote: ["I like the Divers, but they want me want to go to a war."](http://www.shmoop.com/tender-is-the-night/tommy-barban.html) Great page, too.) do
    should == %Q{<p>I loved that quote: <a href="http://www.shmoop.com/tender-is-the-night/tommy-barban.html">"I like the Divers, but they want me want to go to a war."</a> Great page, too.</p>}
  end

  it "I'd link my competitors' mistakes (www.failblog.org) but that'd give them free traffic. So instead I link www.google.com." do
    should == %Q{<p>I'd link my competitors' mistakes (<a href="http://www.failblog.org">www.failblog.org</a>) but that'd give them free traffic. So instead I link <a href="http://www.google.com">www.google.com</a>.</p>}
  end

  it 'Did you know the logo from Teambox has <a href="http://en.wikipedia.org/wiki/Color_theory">carefully selected colors</a>? <img src="http://app.teambox.com/images/header_logo_large.jpg"/>' do
    should == %Q{<p>Did you know the logo from Teambox has <a href="http://en.wikipedia.org/wiki/Color_theory">carefully selected colors</a>? <img src="http://app.teambox.com/images/header_logo_large.jpg" /></p>}
  end

  it 'This commit needs a spec: http://github.com/teambox/teambox/blob/4b54c555d118cd3bc4d4d80fbc59b1eed79b4e80/lib/html_formatting.rb' do
    should == "<p>This commit needs a spec: <a href=\"http://github.com/teambox/teambox/blob/4b54c555d118cd3bc4d4d80fbc59b1eed79b4e80/lib/html_formatting.rb\">http://github.com/teambox/teambox/blob/4b54c555d118cd3bc4d4d80fbc59b1eed79b4e...</a></p>"
  end

  it 'This commit needs a spec: http://github.com/teambox/teambox/commit/4b54c555d118cd3bc4d4d80fbc59b1eed79b4e8' do
    should == "<p>This commit needs a spec: <a href=\"http://github.com/teambox/teambox/commit/4b54c555d118cd3bc4d4d80fbc59b1eed79b4e8\">http://github.com/teambox/teambox/commit/4b54c555d118cd3bc4d4d80fbc59b1eed79b4e8</a></p>"
  end

  it "Lorem ipsum dolor sit amet.\n\n<pre>*lorem* _ipsum_ weird_var_name</pre>\n\nExcepteur sint occaecat cupidatat non proident." do
    should == "<p>Lorem ipsum dolor sit amet.</p>\n\n<pre>*lorem* _ipsum_ weird_var_name</pre>\n\n\n<p>Excepteur sint occaecat cupidatat non proident.</p>"
  end

  it "This is a comment\nwith multiple lines\n\nJordi." do
    should == "<p>This is a comment<br />\nwith multiple lines</p>\n\n<p>Jordi.</p>"
  end
  
  it "Can somebody spec and fix this?\n\nA comment line \"**text**\ntext\" should return a line break with a br tag." do
    should == "<p>Can somebody spec and fix this?</p>\n\n<p>A comment line \"<strong>text</strong><br />\ntext\" should return a line break with a br tag.</p>"
  end

  it "This is a comment with an_underscored_word" do
    should == "<p>This is a comment with an_underscored_word</p>"
  end
  
  it "Why don't you\nhttp://www.google.co.uk/images/logos/ps_logo2.png\nIt?" do
    should == "<p>Why don't you<br />\n<a href=\"http://www.google.co.uk/images/logos/ps_logo2.png\"><img class=\"comment-image\" src=\"http://www.google.co.uk/images/logos/ps_logo2.png\" alt=\"http://www.google.co.uk/images/logos/ps_logo2.png\" /></a><br />\nIt?</p>"
  end
  
  it "Why don't you\nJust http://www.google.co.uk/images/logos/ps_logo2.png\nIt?" do
    should == "<p>Why don't you<br />\nJust <a href=\"http://www.google.co.uk/images/logos/ps_logo2.png\">http://www.google.co.uk/images/logos/ps_logo2.png</a><br />\nIt?</p>"
  end

  it "Should not allow <script>alert(1)</script> tags or weird <a href=\"#\" onmouseover='alert(1)'>tricks</a>" do
    should == "<p>Should not allow  tags or weird <a href=\"#\">tricks</a></p>"
  end
  
  context "Add http:// to links" do
    it "The internet is made of [lolcats](icanhascheezburger.com)" do
      should == "<p>The internet is made of <a href=\"http://icanhascheezburger.com\">lolcats</a></p>"
    end

    it "The internet is made of [memes](www.4chan.org)" do
      should == "<p>The internet is made of <a href=\"http://www.4chan.org\">memes</a></p>"
    end

    it "The internet is made of [random](www.4chan.org/b)" do
      should == "<p>The internet is made of <a href=\"http://www.4chan.org/b\">random</a></p>"
    end
    
    it "The internet is made of [google](http://google.com)" do
      should == "<p>The internet is made of <a href=\"http://google.com\">google</a></p>"
    end
  end

end