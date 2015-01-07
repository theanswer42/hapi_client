require 'date'
require 'csv'
require 'yaml'
require 'fileutils'

require './medhelp_session.rb'

require './hapi_client.rb'

puts "login:"
username = $stdin.readline.strip

puts "password:"
password = $stdin.readline.strip

FileUtils.mkdir_p("./data")

session = MedhelpSession.new
raise "Login unsuccessful" if !session.login(username, password)

hapi_client = HapiClient.new(session)

start_date = Date.parse("2006-01-01")

today = Date.today

CSV_COLUMNS = %w(medhelp_id date time deleted value field_name source_id source_type created_at updated_at)

def data_row(data)
  overrides = {}
  overrides['created_at'] = Time.at(data['created_at'].to_i).strftime("%Y-%m-%d %T")
  overrides['updated_at'] = Time.at(data['created_at'].to_i).strftime("%Y-%m-%d %T")
  t = data['time'].to_i
  hours = "%02d"%(t/3600)
  mins = "%02d"%((t%3600)/60)
  sec = "%02d"%(t%60)

  overrides['time'] = "#{hours}:#{mins}:#{sec}"
  overrides["value"] = data["value"].inspect()

  CSV_COLUMNS.collect {|c| overrides[c] || data[c]}
end



while(start_date < today)
  end_date = start_date + 30
  
  data = hapi_client.get(start_date, end_date, '*')
  start_date = end_date
  next if data.length == 0

  CSV.open("./data/#{start_date.to_s}.csv", "wb") do |csv|
    csv << CSV_COLUMNS
    data.each do |d| 
      csv << data_row(d)
    end
  end

  sleep 5
end



## export in yaml
# while(start_date < today)
#   end_date = start_date + 30
  
#   data = hapi_client.get(start_date, end_date, '*')
#   if data.length > 0
#     output_file = File.open("./data/#{start_date.to_s}.yaml", "wb")
#     output_file << data.to_yaml
#     output_file.close
#   end
#   start_date = end_date
#   sleep 5
# end


