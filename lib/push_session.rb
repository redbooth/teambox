module PushSession
  def self.included(base)
    base.class_eval {
      before_filter do |c|
        User.current.push_session_id = request.headers["X-PushSession-ID"]
      end
    }
  end
end
