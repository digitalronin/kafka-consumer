#!/usr/bin/env ruby

require "bundler/setup"
require "sinatra"

def get_messages
  []
end

get "/" do
  redirect "/messages"
end

get "/messages" do
  erb :messages, locals: { messages: get_messages }
end
