module Websocket
  def broadcast(channel, msg)
    message = {:channel => channel, :data => msg}
    uri = URI.parse("http://localhost:9292/events/listen")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
end