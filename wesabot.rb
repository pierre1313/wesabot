#!/usr/bin/env ruby
require 'campfire/configuration'
require 'campfire/polling_bot'
require 'optparse'

config = Campfire::Configuration.new

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: wesabot.rb [options]"

  opts.separator ""
  opts.separator "Options:"

  opts.on("-c", "--config FILE", "Configuration file (required)") do |path|
    config = Campfire::FileConfiguration.new(path)
  end

  opts.separator "OR"

  opts.on("-t", "--token TOKEN", "API token (required)") do |api_token|
    config.api_token = api_token
  end

  opts.on("-d", "--subdomain SUBDOMAIN", "Campfire subdomain (required)") do |subdomain|
    config.subdomain = subdomain
  end

  opts.on("-r", "--room ROOM", "Campfire room (required, allows multiple values)") do |room|
    config.room = room
  end

  opts.on("-v", "--verbose", "Be verbose") do
    config.verbose = true
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

# check for required options
begin
  optparse.parse!
  config.validate!
rescue Campfire::ConfigurationError, OptionParser::InvalidOption, OptionParser::MissingArgument => e
  puts "#{File.basename($0)}: #{e}"
  puts optparse
  exit(1)
end

OpenSSL::debug = config.verbose?

Campfire::PollingBot.new(config).run