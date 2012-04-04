require 'jumpstart_auth'

class JSTwitter
  attr_reader :client

  def initialize
    puts "Initializing"
    @client = JumpstartAuth.twitter
  end
end