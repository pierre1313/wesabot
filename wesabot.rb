#!/usr/bin/env ruby
require 'campfire/polling_bot'
require 'optparse'

# defaults
options = {
  :debug => false
}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: wesabot.rb [options]"

  opts.separator ""
  opts.separator "Options:"

  opts.on("-t", "--token TOKEN", "API token (required)") { |t| options[:token] = t }
  opts.on("-d", "--domain DOMAIN", "Campfire subdomain (required)") { |d| options[:domain] = d }
  opts.on("-r", "--room ROOM", "Campfire room (required)") { |r| options[:room] = r }
  opts.on("-v", "--verbose", "Be verbose") { options[:debug] = true }
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

# check for required options
begin
  optparse.parse!
  required = [:token, :domain, :room]
  missing = required.select{ |param| options[param].nil? }
  if missing.any?
    puts "Missing options: #{missing.join(', ')}"
    puts optparse
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

OpenSSL::debug = options[:debug]

wes = Campfire::PollingBot.new(
  :token => options[:token],
  :name => options[:name],
  :domain => options[:domain],
  :room => options[:room],
  :debug => options[:debug]
)

wes.run