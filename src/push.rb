require 'webpush'

class PushList
  def initialize()
    @list = []
  end

  def register(subscription)
    @list << subscription
  end

  def push(body)
    message = {
      title: "Hello, Again.",
      body: body,
      icon: "/img/chip.png"
    }

    @list.each do |e|
      Webpush.payload_send(
        message: JSON.generate(message),
        endpoint: e["endpoint"],
        p256dh: e["keys"]["p256dh"],
        auth: e["keys"]["auth"],
        vapid: {
          public_key: ENV['VAPID_PUBLIC_KEY'],
          private_key: ENV['VAPID_PRIVATE_KEY']
        },
      )
    end
  end
end