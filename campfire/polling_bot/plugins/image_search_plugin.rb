require 'httparty'

# plugin to send a tweet to a Twitter account
class ImageSearchPlugin < Campfire::PollingBot::Plugin
  priority 1
  accepts :text_message, :addressed_to_me => true

  def process(message)
    case message.command
    when /(?:photo|image|picture)\s+of:?\s+(?:a:?\s+)?\s*("?)(.*?)\1$/i
      subject = $2
      if photo_links = query_flickr(subject)
        if photo_links.empty?
          bot.say("Couldn't find anything for \"#{subject}\"")
        else
          bot.say_random(photo_links)
        end
      end
      return HALT
    end
  end

  # return array of available commands and descriptions
  def help
    [['(photo|image|picture) of <subject>', "find a random picture on flickr of <subject>"]]
  end

  private

  # post a message to twitter
  def query_flickr(subject)
    options = {:query => {:q => "select * from flickr.photos.search where text=\"#{subject}\""} }
    logger.debug("YQL query #{options[:query][:q]}")

    if proxy = (config && config['proxy']) || ENV['HTTP_PROXY']
      proxy_uri = URI.parse(proxy)
      options.update(:http_proxyaddr => proxy_uri.host, :http_proxyport => proxy_uri.port)
    end

    response = HTTParty.get("http://query.yahooapis.com/v1/public/yql", options)
    logger.debug("Got response #{response.parsed_response.inspect}")
    case response.code
    when 200
      return [] if response["query"]["yahoo:count"] == "0" || response["query"]["results"].nil?
      photos = response["query"]["results"]["photo"]
      photos = [photos] if photos.is_a?(Hash)
      return photos.map {|p| "http://farm%s.static.flickr.com/%s/%s_%s.jpg?v=0" % [p['farm'], p['server'], p['id'], p['secret']]}
    when 403
      bot.say("Sorry, we seem to have hit our query limit for the day.")
      return []
    else
      bot.say("Hmm...didn't work. Got this response:")
      bot.paste(response.body)
      return nil
    end
  end
end
