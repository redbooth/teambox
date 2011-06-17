module PushSession
  def self.included(base)
    base.class_eval {
      before_filter do |c|
        User.current.push_session_id = (request.params['_x-pushsession-id'] || request.headers["X-PushSession-ID"]) if User.current
      end
    }
  end
end
