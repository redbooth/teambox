require 'omniauth/oauth'

module OmniAuth
  module Strategies
    class Google < OmniAuth::Strategies::OAuth
      RESOURCES = {
        :scope => 'https://docs.google.com/feeds/ https://www.google.com/calendar/feeds/ https://www.google.com/m8/feeds/ https://mail.google.com/mail/feed/atom/',
        :request_token_url => 'https://www.google.com/accounts/OAuthGetRequestToken',
        :access_token_url => 'https://www.google.com/accounts/OAuthGetAccessToken',
        :authorize_url => "https://www.google.com/accounts/OAuthAuthorizeToken",
        :list => 'https://docs.google.com/feeds/default/private/full'
      }
      HEADERS = {'GData-Version' => '3.0'}
      
      def initialize(app, consumer_key, consumer_secret)
        # consistently fails if the entire url is not given.
        super(app, :google, consumer_key, consumer_secret, RESOURCES)
      end
      
      def auth_hash
        ui = user_info
        OmniAuth::Utils.deep_merge(super, {
          'uid' => ui['uid'],
          'user_info' => ui,
          'extra' => {'user_hash' => user_hash}
        })
      end
      
      def user_info
        email = user_hash['feed']['author'].first['email']['$t']
        name = user_hash['feed']['author'].first['name']['$t']

        {
          'email' => email,
          'uid' => email,
          'name' => name
        }
      end
      
      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get(RESOURCES[:list] + '?alt=json', HEADERS).body)
      end

      # Monkeypatch OmniAuth to pass the scope in the consumer.get_request_token call - https://github.com/xxx/omniauth/tree/xxx-providers
      def request_phase
        request_token = consumer.get_request_token({:oauth_callback => callback_url}, {:scope => RESOURCES[:scope]})
        (session[:oauth]||={})[name.to_sym] = {:callback_confirmed => request_token.callback_confirmed?, :request_token => request_token.token, :request_secret => request_token.secret}
        r = Rack::Response.new
        r.redirect request_token.authorize_url
        r.finish
      end
    end
  end
end