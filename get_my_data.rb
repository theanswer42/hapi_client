require 'date'

require './medhelp_session.rb'

require './hapi_client.rb'

puts "login:"
username = $stdin.readline.strip

puts "password:"
password = $stdin.readline.strip

session = MedhelpSession.new
raise "Login unsuccessful" if !session.login(username, password)


hapi_client = HapiClient.new(session)
data = hapi_client.get(Date.parse('2012-01-01'), Date.parse('2012-06-01'), '*')

puts data.size

