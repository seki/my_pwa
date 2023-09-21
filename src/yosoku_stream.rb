require 'driq'
require 'driq/webrick'

class YosokuStream
  def initialize
    @src = Driq::EventSource.new
  end

  def on_stream(req, res)
    last_event_id = req["Last-Event-ID"] || 0
    p [:last_event_id, last_event_id]
    res['Access-Control-Allow-Origin'] = '*'
    res.content_type = 'text/event-stream'
    res.chunked = true
    res.body = WEBrick::ChunkedStream.new(Driq::EventStream.new(@src, last_event_id))
  end

  def on_news(data)
    return unless data['topic'] == 'yosoku'
    pp data
    @src.write(data.to_json)
  end
end