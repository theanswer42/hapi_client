require './medhelp_session.rb'

# This is the hapi api client
class HapiClient
  attr_reader :session
  def initialize(session)
    @session = session
  end

  def base_path
    "/hapi/v1/users/#{session.user['id']}"
  end
  
  def vitals_base_path
    "#{base_path}/vitals"
  end

  def get(start_date, end_date, field_names=nil)
    unless field_names
      field_names = "*"
    else
      field_names = field_names.to_json
    end
    
    data = []
    
    body = session.get_json(vitals_base_path, {start_date: start_date.to_s, end_date: end_date.to_s, field_names: field_names})
    
    while true
      body = body['data']
      
      data = data + body['data']
      puts "Total = #{body['total']}, offset=#{body['offset']}, limit=#{body['limit']}, query_id=#{body['query_id']}"
      break if body['total'] <= body['data'].length + body['offset']
      
      offset = body['offset'] + body['data'].length
      limit = 100
      query_id = body['query_id']
      
      body = session.get_json(vitals_base_path, {query_id: query_id, offset: offset, limit: limit})
    end
    
    data
  end

end
