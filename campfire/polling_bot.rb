# PollingBot - a bot that polls the room for messages
require 'campfire/bot'
require 'campfire/message'


module Campfire
  class PollingBot < Bot
    require 'campfire/polling_bot/plugin'
    attr_accessor :plugins
    HEARTBEAT_INTERVAL = 3 # seconds

    def initialize(config)
      # load plugin queue, sorting by priority
      super
      self.plugins = Plugin.load_all(self)
    end

    # main event loop
    def run
      # set up a heartbeat thread for plugins that want them
      Thread.new do
        loop do
          plugins.each {|p| p.heartbeat if p.respond_to?(:heartbeat)}
          sleep HEARTBEAT_INTERVAL
        end
      end

      logger.debug "listening..."

      room.listen do |message|
        klass = Campfire.const_get(message[:type])
        message = klass.new(message)
        logger.debug "processing #{message} (#{message.person} - #{message.body})"
        process(message)
        logger.debug "done processing #{message}"
      end

    rescue Exception => e # leave the room if we crash
      unless e.kind_of?(SystemExit)
        log_error(e)
        room.leave
        exit 1
      end
    end

    def process(message)
      if message.person == self.name || message.person_full_name == self.name
        # ignore messages from ourself
        return
      end

      plugins.each do |plugin|
        begin
          if plugin.accepts?(message)
            logger.debug "sending to plugin #{plugin} (priority #{plugin.priority})"
            status = plugin.process(message)
            if status == Plugin::HALT
              logger.debug "plugin chain halted"
              break
            end
          end
        rescue Exception => e
          log_error(e)
        end
      end
    end

    # determine if a message is addressed to the bot. if so, store the command in the message
    def addressed_to_me?(message)
      if m = message.body.match(/^\b#{name}[,:]\s*(.*)/i) || message.body.match(/^\s*(.*?)[,]?\b#{name}[.!?\s]*$/i)
        message.command = m[1]
      end
    end

    def log_error(e)
      logger.error "Exception: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
    end

  end
end
