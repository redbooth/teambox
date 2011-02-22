clients = {}

Juggernaut.subscribe do |event, data|
  case event
  when :subscribe
    clients[data.session_id] = data
  when :unsubscribe
    clients.delete(data.session_id)
  end
end