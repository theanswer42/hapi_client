require './medhelp_session.rb'

# This is the hapi api client
class HapiClient
  def initialize(session)
    @session = session
  end

  def base_path
    "/hapi/v1/users/#{@session.user['id']}"
  end
  
  def vitals_base_path
    "{base_path}/vitals"
  end

  def get(start_date, end_date, field_names=nil)
    unless field_names
      field_names = "*"
    else
      field_names = field_names.to_json
    end
    
    body = session.get_json(vitals_base_path, {start_date: start_date.to_s, end_date: end_date.to_s, field_names: field_names})
  end

end
