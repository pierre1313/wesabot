require 'httparty'

# plugin to search twitter
class TwitterSearchPlugin < Campfire::PollingBot::Plugin
  priority 1
  accepts :text_message, :addressed_to_me => true

  def process(message)
    searched = false

    case message.command
    when /(?:(?:what(?:'s)? (?:(?:are )?people|(?:is |does )?every(?:one|body)) (?:saying|tweeting|think) about)|what's the word on)\s+(?:the )?(.*?)[.?!]?\s*$/i
      subject = $1
      tweets = search_twitter(subject)
      if tweets.any?
        tweets.each {|t| bot.tweet(t) }
      else
        bot.say("Couldn't find anything for \"#{subject}\"")        
      end
      return HALT
    end
  end

  # return array of available commands and descriptions
  def help
    [
      ["what are (people|is everyone) saying about <subject>", "search twitter for tweets on <subject>"],
      ["what's the word on <subject>", "search twitter for tweets on <subject>"],
    ]
  end

private

  # construct a twitter url from the given response json
  def twitter_url(json)
    "http://twitter.com/#{json['from_user']}/status/#{json['id']}"
  end

  def search_twitter(subject)
    tweets = []
    res = HTTParty.get("http://search.twitter.com/search.json",
                        :query => { :q => subject, :result_type => "mixed" }) # also "popular" and "recent"
    case res.code
    when 200
      tweets = res["results"].first(5).map {|r| twitter_url(r) }
    else
      bot.say("Hmm...didn't work. Got this response:")
      bot.paste(res.body)
    end

    return tweets
  end
end
