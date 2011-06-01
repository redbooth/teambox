#require 'json'

##Uses JSON as marshal format for Hash
#class JSONHash < Hash
  #def _dump(level)
    #self.to_json
  #end

  #def self._load(data)
    #self[JSON.parse(data)]
  #end
#end

#module JSONHashSession

  ##Use JSONHash instead of simple hash, so that the marshal format is json
  #def get_session(env, sid)
    #sid ||= generate_sid
    #begin
      #session = @pool.get(sid) || JSONHash.new
    #rescue Errno::ECONNREFUSED
      #session = JSONHash.new
    #end
    #[sid, session]
  #end

  #def set_session(env, sid, session_data)
    #options = env['rack.session.options']
    #@pool.set(sid, JSONHash[session_data], options)
    #return(::Redis::Store.rails3? ? sid : true)
  #rescue Errno::ECONNREFUSED
    #return false
  #end
#end

#class ActionDispatch::Session::RedisSessionStore < ActionDispatch::Session::AbstractStore
  #include JSONHashSession
#end

