# encoding: utf-8
require "sinatra"
require "json"
require "httparty"
require "redis"
require "dotenv"

configure do
  # Load .env vars
  Dotenv.load
  # Disable output buffering
  $stdout.sync = true
  
  # Set up redis
  case settings.environment
  when :development
    uri = URI.parse(ENV["LOCAL_REDIS_URL"])
  when :production
    uri = URI.parse(ENV["REDISCLOUD_URL"])
  end
  $redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
end

# Handles the POST request made by the Slack Outgoing webhook
# Params sent in the request:
# 
# token=abc123
# team_id=T0001
# channel_id=C123456
# channel_name=test
# timestamp=1355517523.000005
# user_id=U123456
# user_name=Steve
# text=trebekbot jeopardy me
# trigger_word=trebekbot
# 
post "/" do
  @params = params
  begin
    puts "[LOG] #{params}"
    track_talk
  rescue => e
    puts "[ERROR] #{e}"
    response = ""
  end
  status 200
  body json_response_for_slack(response)
end

# Puts together the json payload that needs to be sent back to Slack
# 
def json_response_for_slack(reply)
  response = { text: reply, link_names: 1 }
  response[:username] = ENV["BOT_USERNAME"] unless ENV["BOT_USERNAME"].nil?
  response[:icon_emoji] = ENV["BOT_ICON"] unless ENV["BOT_ICON"].nil?
  response[:channel] = ENV["CHANNEL"] unless ENV["CHANNEL"].nil?
  response.to_json
end

def track_talk
  channel = @params[:channel_name]
  if active? channel
    puts "[LOG] [TTL] channel #{channel} is still active and will be for #{($redis.ttl "#{channel}:lock")/60} minutes." 
  else
    log_talk
  end
end

def log_talk
  key = "#{@params[:channel_name]}:talk"
  user = @params[:user_name]
  ENV["NUMBER_OF_CHATTERS"].nil? ? crowd = 3 : crowd = ENV["NUMBER_OF_CHATTERS"]
  ENV["MINUTES"].nil? ? minutes = 2 * 60 : minutes = ENV["MINUTES"].to_i * 60
  if $redis.exists key # has someone recently spoken?
    unless $redis.sismember key, user # and are they repeating themselves?
      puts "[LOG] [SADD] adding #{user} the list of people talking."
      $redis.sadd key, user
      # $redis.expire key, minutes # If I want the activity to be recharged when a second person speaks. Kind of think no.
      unless $redis.smembers(key).length < crowd # uh-oh, we have a crowd!
        activate @params[:channel_name]
      end
    end
  else # let's make a note that someone is speaking.
    $redis.sadd key, user
    $redis.expire key, minutes 
    puts "[LOG] [SADD] established that #{user} is speaking, possibly alone, in #{@params[:channel_name]}."
  end
end

def active?(channel)
  if $redis.exists "#{channel}:lock"
    true
  else
    false
  end
end

def activate(channel)
  ENV["WAIT_TIME"].nil? ? wait_time = 0 : wait_time = ENV["WAIT_TIME"].to_i * 60
  message = "#{channel} set as active at #{Time.now}"
  $redis.setex "#{channel}:lock", wait_time, message
  puts "[LOG] [SETEX] #{message}"
  "There is some activity in ##{channel}’s bullpen!"
end
