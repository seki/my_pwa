require_relative '../src/my_s3'
require 'json'

s3 = MyS3.new

data = {
  'topic' => 'yosoku',
  'urgency' => 'normal', # normal, very-low, low, normal, high
  'title' => '予測の通知です！',
  'body' => 'Hello, World.',
  # 'icon' => "/img/chip.png"
}

s3.put_object("yosoku.json", data.to_json)
pp s3.get_object('yosoku.json').body.read