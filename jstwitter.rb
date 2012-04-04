require 'jumpstart_auth'
require 'bitly'
require 'klout'

class JSTwitter
  attr_reader :client

  def initialize
    puts "Initializing"
    @client = JumpstartAuth.twitter
    @k = Klout::API.new('6f2zva63qwtan3hgwvesa7b8')
  end
  
  def run
    puts "Welcome to the JSL Twitter Client!"
    
    command = ""
    while command != "q"
      printf "enter command: "
      parts = gets.chomp.split(" ")
      command = parts[0]
      
      case
         when 'q' then puts "Goodbye!"
         when 't' then tweet(parts[1..-1].join(" "))
         when 'dm' then dm(parts[1], parts[2..-1].join(" "))
         when 'spam' then spam_my_followers(parts[1..-1].join(" "))
         when 'elt' then everyones_last_tweet
         when 's' then shorten_url(parts[1..-1].join(" "))
         when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
         when 'k' then klout_score
         else
           puts "Sorry, I don't know how to '#{command}'"
       end
       
    end
  end
  
  def tweet(message)
    if (message.length > 140) puts "Uh oh, message is too long. Try again!"
     @client.update(message) unless message.length > 140
  end
  
  def dm(target, message)
    dm_command = "d" + " " + target + " " + message
    followers = followers_list
    if followers.include?(target) 
      tweet(dm_command)
    else
      puts "Sorry, you can only send DMs to people who follow you."
    end
  end
  
  def followers_list
    @client.followers.collect{|follower| follower.screen_name}
  end
  
  def spam_my_followers(message)
    followers = followers_list
    
    followers.each do |follower|
      dm(follower, message)
    end
  end
  
  def everyones_last_tweet
    friends = @client.friends
    friends.each do |friend|
      # find each friends last message - friend.status.source
      # print each friend's screen_name - friend.id
      # print each friend's last message - puts friend.status.source
      
      puts friend.id 
           + " just said this on " 
           + friend.status.created_at.strftime("%A, %b %d")
           + "... \n"
           + friend.status.source
           
      puts ""  # Just print a blank line to separate people
    end
  end
  
  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    Bitly.use_api_version_3
    
    return bitly.shorten(original_url).short_url
  end
  
  def klout_score
    friends = followers_list
    highest_klout = ["",0]
    friends.each do |friend|
      score = @k.klout(friend)
      puts friend.id + " has a Klout of: " + score  + "\n"
      if (score > highest_klout[1]) 
        highest_klout[0] = friend.id
        highest_klout[1] = score
      end
    end
    puts "Your friend '" + highest_klout[0] + "' has the highest score of: " + highest_klout[1]
  end
  
end

jst = JSTwitter.new
jst.run