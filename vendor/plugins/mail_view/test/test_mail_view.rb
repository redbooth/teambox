require 'test/unit'
require 'rack/test'

require 'mail_view'
require 'mail'

require 'tmail'

class TestMailView < Test::Unit::TestCase
  include Rack::Test::Methods

  class Preview < MailView
    def plain_text_message
      Mail.new do
        to 'josh@37signals.com'
        body 'Hello'
      end
    end

    def html_message
      Mail.new do
        to 'josh@37signals.com'

        content_type 'text/html; charset=UTF-8'
        body '<h1>Hello</h1>'
      end
    end

    def tmail_html_message
      TMail::Mail.parse(html_message.to_s)
    end

    def multipart_alternative
      Mail.new do
        to 'josh@37signals.com'

        text_part do
          body 'This is plain text'
        end

        html_part do
          content_type 'text/html; charset=UTF-8'
          body '<h1>This is HTML</h1>'
        end
      end
    end

    def tmail_multipart_alternative
      TMail::Mail.parse(multipart_alternative.to_s)
    end
  end

  def app
    Preview
  end

  def test_index
    get '/'
    assert last_response.ok?

    assert_match(/plain_text_message/, last_response.body)
    assert_match(/html_message/, last_response.body)
    assert_match(/multipart_alternative/, last_response.body)
  end

  def test_not_found
    get '/missing'
    assert last_response.not_found?
  end

  def test_plain_text_message
    get '/plain_text_message'
    assert last_response.ok?

    assert_match(/Hello/, last_response.body)
  end

  def test_html_message
    get '/html_message'
    assert last_response.ok?

    assert_match(/<h1>Hello<\/h1>/, last_response.body)
  end

  def test_multipart_alternative
    get '/multipart_alternative'
    assert last_response.ok?

    assert_match(/<h1>This is HTML<\/h1>/, last_response.body)
    assert_match(/View plain text version/, last_response.body)
  end

  def test_multipart_alternative_as_html
    get '/multipart_alternative.html'
    assert last_response.ok?

    assert_match(/<h1>This is HTML<\/h1>/, last_response.body)
    assert_match(/View plain text version/, last_response.body)
  end

  def test_multipart_alternative_as_text
    get '/multipart_alternative.txt'
    assert last_response.ok?

    assert_match(/This is plain text/, last_response.body)
    assert_match(/View HTML version/, last_response.body)
  end

  def test_tmail_html_message
    get '/tmail_html_message'
    assert last_response.ok?

    assert_match(/<h1>Hello<\/h1>/, last_response.body)
  end

  def test_tmail_multipart_alternative
    get '/tmail_multipart_alternative'
    assert last_response.ok?

    assert_match(/<h1>This is HTML<\/h1>/, last_response.body)
    assert_match(/View plain text version/, last_response.body)
  end
end
