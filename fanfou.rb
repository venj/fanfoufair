require 'rubygems'
require 'json'
require 'curb'
require 'fanfou_user'

class Fanfou
  def initialize(username=nil, password=nil)
    @username = username
    @api_base = 'http://api.fanfou.com'
    @curl = Curl::Easy.new
    @curl.username = @username
    @curl.http_auth_types = [:basic]
    if (!password.nil? and (password.strip != ''))
      @curl.password = password
    else
      @curl.username = 'iosfan' # Besure to change to your own test
      @curl.password = 'zzzzzz' # username and password.
    end
  end
  
  def fetch_login
    curl = Curl::Easy.new
    curl.url = "http://fanfou.com/login?fr=%2f"
    curl.perform
    curl.body_str
  end
  
  def authenticate
    @curl.url = @api_base + '/account/verify_credentials.json'
    @curl.perform
    if @curl.response_code == 200
      true
    else
      false
    end
  end
  
  def show(uid)
    @curl.url = @api_base + "/users/show.json?id=" + @curl.escape(uid)
    @curl.perform
    FanfouUser.new(JSON.parse(@curl.body_str))
  end
  
  def check_unfair
    friends_url = @api_base + '/friends/ids/' + @username + '.json'
    followers_url = @api_base + '/followers/ids/' + @username + '.json'
    @curl.url = friends_url
    @curl.useragent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_5; zh-cn) AppleWebKit/533.19.4 (KHTML, like Gecko) Version/5.0.3 Safari/533.19.4"
    @curl.perform
    if @curl.response_code != 200
      raise StandardError.new "User is private!"
    end
    friends = JSON.parse(@curl.body_str)
    @curl.url = followers_url
    @curl.perform
    followers = JSON.parse(@curl.body_str)
    # return [friends delta, follower delta]
    [friends - followers, followers - friends]
  end
  
  def unfollow(uid)
    @curl.url = @api_base + '/friendships/destroy.json'
    @curl.http_post("id=#{@curl.escape(uid)}")
    @curl.perform
    if @curl.response_code == 200
      true
    else
      false
    end
  end
  
  def follow(uid)
    @curl.url = @api_base + '/friendships/create.json'
    @curl.http_post("id=#{@curl.escape(uid)}")
    @curl.perform
    if @curl.response_code == 200
      true
    else
      false
    end
  end
  
  def unfollow_all
    delta = self.check_unfair
    to_unfollow = delta[0]
    to_unfollow.each do |u|
      self.unfollow u
    end
  end
  
  def follow_all
    delta = self.check_unfair
    to_follow = delta[1]
    to_follow.each do |u|
      self.follow u
    end
  end
  
end

# Testing
if __FILE__ == $0
  f = Fanfou.new('ilovemac')
  if f.authenticate
    a = f.check_unfair
    puts 'who is not following you:', a[0]
    puts 'who you are not following:', a[1]
    #f.unfollow_all
    #f.follow_all
  end
end