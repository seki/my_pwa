require 'webrick'
require 'json'
require 'webpush'
require 'open-uri'
require 'net/http'
require_relative 'src/push'

env_path = __dir__ + "/env.rb"
puts env_path
load(env_path) if File.exist?(env_path)

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
  Thread.new do
    $list.push("Hello, Again")
  end
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
  res.content_type = "application/json; charset=UTF-8"
  it = { "put" => req.path_info}.to_json
  res.body = it
}

server.mount_proc('/') {|req, res|
  res.content_type = "text/html; charset=UTF-8"
  res.body = $index.result(binding)
}

trap(:INT){exit!}
server.start
