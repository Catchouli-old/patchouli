#!/usr/bin/ruby

require 'cinch'
require 'yt'
require 'open-uri'
require 'htmlentities'

$delay_time = 3
$last_attempt = {}

$regexes =
{
  "talkhaus.raocow.com" => /raocow's talkhaus &bull; (.*)/
}

Yt.configure { |c| c.api_key='AIzaSyBcrqOBwNqiYeZoJzwnmZBVtF_OduB8w-4' }

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "Patchouli"
    c.user = "Patchouli"
    c.realname = "Patchouli"
    c.server = "irc.rena.so"
    c.channels = ["#rena"]
  end

  on :message do |m|

    httpurlpat = %r{\b(https?://)(www.)?(.*)(/[^ ]*)}
    httpnoparsepat = %r{#\b+(https?://)(www.)?(.*)(/[^ ]*)}

    if /^[\.!]help$/.match(m.message)
        m.reply "http://horseysurprise.tumblr.com/"
        m.reply "Horsey Surprise"
    end

    if httpnoparsepat.match(m.message)
      return
    end

    httpurlpat.match(m.message) do |match|

      if $last_attempt[m.user.host] && $last_attempt[m.user.host] + $delay_time > Time.now

        return

      else

        $last_attempt[m.user.host] = Time.now

      end

      url = match[0]
      hostname = match[3]

      case hostname
      when "youtube.com"

        pat = /(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})/

        pat.match(m.message) do |match|
          video_id = match[1]

          video = Yt::Video.new id: video_id

          if video
            m.reply "Video name: #{video.title}"
          end
        end

      when "talkhaus.raocow.com"

        return
  
      else

        if open(url).read =~ /<title>(.*?)<\/title>/

          title = $1

          if $regexes[hostname] && title =~ $regexes[hostname]

            m.reply HTMLEntities.new.decode $1

          else

            m.reply HTMLEntities.new.decode(title).split.join(" ")

          end

        end

      end

    end

  end
end

bot.start
