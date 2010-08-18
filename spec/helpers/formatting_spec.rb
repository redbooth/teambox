require 'spec_helper'

describe HtmlFormatting, 'Should apply our special Markdown' do
  
  subject do
    comment = Comment.new :body => description
    comment.save!
    comment.body_html.strip
  end

  it "Should allow Youtube videos"

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

  it "This is a comment with an_underscored_word" do
    should == "<p>This is a comment with an_underscored_word</p>"
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