require 'webpush'
require_relative 'store'

class PushList
  def initialize()
    @store = Not::MyStore
  end

  def register(subscription)
    begin
      @store.subscription_register(subscription)
    rescue
      pp $!
    end
  end

  def push(body)
    message = {
      title: "Hello, Again.",
      body: body,
      icon: "/img/chip.png"
    }

    failed = Not::MyStore.subscription_list.find_all do |e|
      begin
        Webpush.payload_send(
          message: JSON.generate(message),
          endpoint: e["endpoint"],
          p256dh: e["p256dh"],
          auth: e["auth"],
          vapid: {
            subject: "mailto:m_seki@mac.com",
            public_key: ENV['VAPID_PUBLIC_KEY'],
            private_key: ENV['VAPID_PRIVATE_KEY']
          },
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