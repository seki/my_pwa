require 'webrick'
require 'json'
require 'webpush'
require 'open-uri'
require 'net/http'
require_relative 'src/push'
require_relative 'src/my_s3'

env_path = __dir__ + "/env.rb"
puts env_path
load(env_path) if File.exist?(env_path)
$s3 = MyS3.new

port = Integer(ENV['PORT']) rescue 8009
server = WEBrick::HTTPServer.new({
  :Port => port,
  :FancyIndexing => false
})

$index = ERB.new(File.read('index.html'))
$list = PushList.new

Dir.glob('assets/*') do |path|
  server.mount('/' + File.basename(path), WEBrick::HTTPServlet::FileHandler, path)
end

server.mount_proc('/test') {|req, res|
  it = { "hmm" => "will send"}.to_json
  $list.queue.push({'body' => 'Hello, Again'})
  res.body = it
}

server.mount_proc('/push') {|req, res|
  post = JSON.parse(req.body)
  pp post
  $list.register(post)
  res.content_type = "application/json; charset=UTF-8"
  it = { "registered" => "ok"}.to_json
  res.body = it
}

server.mount_proc('/put') {|req, res|
  pp req.path_info
  key = req.path_info.dup
  key[0] = '' if key[0] == '/' 
  pp [:key, key]
  begin
    data = JSON.parse($s3.get_object(key).body.read)
    $list.queue.push(data)
  rescue
    pp $!
  end
  res.content_type = "application/json; charset=UTF-8"
  it = { "put" => key}.to_json
  res.body = it
}

server.mount_proc('/') {|req, res|
  res.content_type = "text/html; charset=UTF-8"
  res.body = $index.result(binding)
}

trap(:INT){exit!}
server.start
