require 'webpush'
require 'thread'
require_relative 'store'

class PushList
  def initialize()
    @store = Not::MyStore
    @queue = Queue.new
    @worker = worker
  end
  attr_reader :queue

  def register(subscription)
    begin
      @store.subscription_register(subscription)
    rescue
      pp $!
    end
  end

  def worker
    Thread.new do
      while true
        begin
          data = @queue.pop
          push(data)
        rescue
          pp $!
        end
      end
    end
  end

  def push(body)
    message = {
      title: body['title'] || 'test-push',
      body: body['body'],
      icon: body['icon'] || "/img/chip.png"
    }
    urgency = body['urgency'] || 'normal'

    message_json = JSON.generate(message)
    failed = Not::MyStore.subscription_list.find_all do |e|
      begin
        Webpush.payload_send(
          message: message_json,
          endpoint: e["endpoint"],
          p256dh: e["p256dh"],
          auth: e["auth"],
          vapid: {
            subject: "mailto:m_seki@mac.com",
            public_key: ENV['VAPID_PUBLIC_KEY'],
            private_key: ENV['VAPID_PRIVATE_KEY']
          },
          urgency: urgency
        )
        false
      rescue
        pp e
        pp $!
        true
      end
    end
    pp failed
    pp [:size, failed.size]
  end
end