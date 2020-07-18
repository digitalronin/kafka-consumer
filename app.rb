#!/usr/bin/env ruby

require "bundler/setup"
require "sinatra"
require 'tempfile'

def initialize_kafka
  start_consumer

  at_exit do
    puts "at_exit...."
  end
end

def start_consumer
  Thread.new do
    begin
      while true
        puts "#{Time.now}: consume...."
        sleep 3
      end
    rescue Exception => e
      puts 'CONSUMER ERROR'
      puts "#{e}\n#{e.backtrace.join("\n")}"
      exit(1)
    end
  end
end

configure do
  initialize_kafka
end

get "/" do
  redirect "/messages"
end

get "/messages" do
  erb :messages, locals: { messages: [] }
end
