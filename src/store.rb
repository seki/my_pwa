require "sqlite3"
require 'time'
require "monitor"
require "pp"
require 'securerandom'

class Not
  class Store
    include MonitorMixin

    def as_time(time)
      time.utc.strftime("%Y-%m-%d %H:%M:%S")
    end

    def to_time(str)
      Time.parse(str + " UTC")
    end

    def initialize(fname)
      super()
      @db = SQLite3::Database.new(fname)
      @db.results_as_hash = true
    end

    def close
      @db.close if @db
    ensure
      @db = nil
    end

    def subscription_create_table
      sql =<<EOQ
create table subscription (
    endpoint text
    , p256dh text
    , auth text
    , primary key(endpoint));
EOQ
      synchronize do
        @db.execute(sql)
      end
    end

    def subscription_list
      sql =<<EOB
select * from subscription;
EOB
      synchronize do
        @db.execute(sql)
      end
    end

    def subscription_register(e)
      sql =<<EOQ
INSERT OR REPLACE INTO subscription (endpoint, p256dh, auth)
  values (:endpoint, :p256dh, :auth);
EOQ
      synchronize do
        endpoint = e["endpoint"]
        p256dh = e["keys"]["p256dh"]
        auth = e["keys"]["auth"]

        @db.execute(sql,
          :endpoint => endpoint, :p256dh => p256dh, :auth=> auth
        )
      end
    end

    def subscription_delete(endpoint)
      sql =<<EOQ
delete from subscription where endpoint = :endpoint;
EOQ
      synchronize do
        @db.execute(sql,
          :endpoint => endpoint
        )
      end
    end

    def keys_create_table
      sql =<<EOQ
    create table keys (
    app_key text
    , secret_key text
    , email text
    , primary key(app_key));
EOQ
      synchronize do
        @db.execute(sql)
      end
    end

    def keys_register(app, secret, email)
      sql =<<EOQ
insert into keys (app_key, secret_key, email)
  values (:app, :secret, :email);
EOQ
      synchronize do
        @db.execute(sql,
          :app => app, :secret => secret, :email => email
        )
      end
    end

    def keys(app)
      sql =<<EOB
select * from keys where app_key=:app;
EOB
      synchronize do
        @db.execute(sql, :app => app).to_a.dig(0)
      end
    end

    def gen_keys(email)
      app = SecureRandom.hex(10)
      client = SecureRandom.hex(13)
      keys_register(app, client, email)
    end
  end

  MyStore = Store.new(__dir__ + '/../data/store.db')
  MyStore.keys_create_table rescue nil
end

if __FILE__ == $0
  s = Not::MyStore
  s.gen_keys('m_seki@mac.com')
  pp s.keys('1aqnzp4ydkbh')
end

