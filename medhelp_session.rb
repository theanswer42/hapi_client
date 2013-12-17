gem 'rest-client'
require 'rest_client'

BASE_URLS = {
  :production => 'www.medhelp.org',
  :cluster => 'partner1.medhelp.ws'
}

class MedhelpSession
  attr_accessor :cookies, :user
  def initialize(env=:production)
    @user = nil
    @cookies = {}
    @base_url = BASE_URLS[env]
  end

  def login(name, password)
    response = self.get('/account/login')
    token = response.body.match(/<meta name=\"csrf-token\" content=\"(.*)\"\/>/)[1]
    token = CGI.unescape_html(token)
    
    params = {"utf8" => "&#x2713;", 'authenticity_token' => token, 'user[login]' => name, 'user[password]' => password}
    response = self.post('/account/login', params)
    
    info = self.get_json('/account/info')
    @user = info['data']['user']
    return @user['id']
  end
  
  def url_for_path(path)
    "https://#{@base_url}#{path}"
  end

  def get(path, params={})
    query_string = params.to_a.collect {|kv| "#{kv[0]}=#{CGI.escape(kv[1].to_s)}" }.join("&")
    url = self.url_for_path(path)
    if !query_string.empty?
      url = "#{url}?#{query_string}"
    end
    begin
      puts "Calling #{url}"
      response = RestClient.get url, {:cookies => @cookies}
      @cookies.merge!(response.cookies)
    rescue RestClient::Exception => e
      response = e.response
      @cookies.merge!(response.cookies)
    end
    return response
  end
  
  def get_json(path, params={})
    response = get(path, params)
    body = JSON.load(response.body)
    return body
  end
  
  # For now, this is a very simple POST, and does not support mixing 
  # query params and params submitted in the body, or other things 
  # submitted as a body, like a json content body.
  def post(path, params)
    begin
      response = RestClient.post url_for_path(path), params, {:cookies => @cookies}
      @cookies.merge!(response.cookies)
    rescue RestClient::Exception => e
      response = e.response
      @cookies.merge!(response.cookies)
    end
    return response
  end
end

