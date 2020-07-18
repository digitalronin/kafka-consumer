#!/usr/bin/env ruby

require "bundler/setup"
require 'kafka'
require "sinatra"
require 'tempfile'

KAFKA_TOPIC = ENV.fetch('KAFKA_TOPIC', 'messages')
GROUP_ID = ENV.fetch('KAFKA_CONSUMER_GROUP', 'heroku-kafka-demo')

def with_prefix(name)
  "#{ENV['KAFKA_PREFIX']}#{name}"
end

def initialize_kafka
  tmp_ca_file = Tempfile.new('ca_certs')
  tmp_ca_file.write(ENV.fetch('KAFKA_TRUSTED_CERT'))
  tmp_ca_file.close

  consumer_kafka = Kafka.new(
    seed_brokers: ENV.fetch('KAFKA_URL'),
    ssl_ca_cert_file_path: tmp_ca_file.path,
    ssl_client_cert: ENV.fetch('KAFKA_CLIENT_CERT'),
    ssl_client_cert_key: ENV.fetch('KAFKA_CLIENT_CERT_KEY'),
    ssl_verify_hostname: false,
  )

  $consumer = consumer_kafka.consumer(group_id: with_prefix(GROUP_ID))
  $recent_messages = []

  start_consumer

  at_exit do
    tmp_ca_file.unlink
  end
end

def start_consumer
  Thread.new do
    $consumer.subscribe(with_prefix(KAFKA_TOPIC))
    begin
      $consumer.each_message do |message|
        $recent_messages << message
        $recent_messages.shift if $recent_messages.length > 10
        puts "consumer received message! local message count: #{$recent_messages.size} offset=#{message.offset}"
      end
    rescue Exception => e
      puts 'CONSUMER ERROR'
      puts "#{e}\n#{e.backtrace.join("\n")}"
      exit(1)
    end
  end
end

get "/" do
  redirect "/messages"
end

get "/messages" do
  erb :messages, locals: { recent_messages: $recent_messages }
end
