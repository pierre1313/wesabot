# Plugin to allow Wes to update and reload himself
class ReloadPlugin < Campfire::PollingBot::Plugin
  accepts :text_message, :addressed_to_me => true

  def process(message)
    case message.command
    when /^reload/i
      bot.say("k")
      system("git pull origin master")
      exec *INVOCATION
      return HALT
    end
  end

  # return array of available commands and descriptions
  def help
    [['reload', "update and reload #{bot.name}"]]
  end
end
