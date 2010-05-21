#!/usr/bin/env ruby
require 'campfire/polling_bot'
OpenSSL::debug = true

wes = Campfire::PollingBot.new(
  :token => 'your_bots_api_token',
  :name => 'Wes', # the name of your bot
  :domain => 'campfire_domain', # <domain>.campfirenow.com
  :ssl => true, # or not, if you like to live dangerously
  :proxy => 'proxy.example.com:8080', # optional
  :room => 'Room Name', # the Campfire room to join
  :debug => true # print out debuggy goodness
)

if ARGV[0]
  wes.say(ARGV[0]) # just say something
else
  wes.run # enter the room and hang out
end
