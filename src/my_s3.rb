require 'aws-sdk-s3'

class MyS3
  def initialize
    credentials = Aws::Credentials.new(ENV['S3_ACCESS_KEY_ID'], ENV['S3_SECRET_ACCESS_KEY'])
    region = ENV['S3_REGION'] || 'us-west-2'
    Aws.config.update(
      region: region,
      credentials: credentials
    )
    @s3 = Aws::S3::Client.new
    @bucket = "not-log"
  end
  attr_reader :s3, :bucket

  def put_object(key, body)
    @s3.put_object(bucket: @bucket, key: key, body: body)
  end

  def get_object(key)
    @s3.get_object(bucket: @bucket, key: key)
  end

  def list_objects(prefix="")
    @s3.list_objects(bucket: @bucket, prefix: prefix)
  end

  def presigned(key)
    signer = Aws::S3::Presigner.new
    signer.presigned_url(
      :get_object, bucket: @bucket, key: key
    )
  end

  def time_to_key(time)
    Time.at((time.to_f / 600).ceil * 600).localtime.strftime("%Y%m%dT%H%M%S.csv")
  end
end

if __FILE__ == $0
  s3 = MyS3.new
  s3.put_object("hello_world.txt", "Hello, World.")
end