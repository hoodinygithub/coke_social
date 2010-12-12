require "rest_client"
require "cgi"
require "json"

class FacebookConnect
  settings = YAML.load_file("#{RAILS_ROOT}/config/facebook.yml")
  APP_ID = settings["appid"]
  SECRET = settings["secret"]
  AUTH_URL = settings["authorize_url"]
  TOKEN_URL = settings["access_token_url"]
  PROFILE_URL = settings["profile_url"]
  
  AUTH_PARAMS = { :client_id => APP_ID, :client_secret => SECRET }
  
  def self.parse_code(p_code, p_host)
    if p_code.empty?
      Rails.logger.error "Facebook code is empty: #{p_code}"
      return nil
    end
    
    params = AUTH_PARAMS.merge :code => p_code, :redirect_uri => p_host.ends_with?("/login/") ? p_host : "#{p_host}/login/"
    
    Rails.logger.info "#{TOKEN_URL}?#{params.to_query}"
    response = RestClient.get "#{TOKEN_URL}?#{params.to_query}"
    Rails.logger.info response.to_str
    
    if response.code == 200
      # response_params = response_str.split("&").map{|param| param.split("=")}.inject({}) { |result, param| result[param[0]] = param[1]; result }
      response_params = CGI::parse(response.to_str)
      access_token = response_params["access_token"].first
      expires = response_params["expires"].first
      parse_access_token(access_token, expires)
    else
      Rails.logger.error response.inspect
      return nil
    end
  end

  def self.parse_access_token(p_token, p_expires)
    # TODO: use p_expires somehow?
    params = { :access_token => p_token }
    Rails.logger.info "#{PROFILE_URL}?#{params.to_query}"
    response = RestClient.get "#{PROFILE_URL}?#{params.to_query}"
    Rails.logger.info response.inspect
    if response.code == 200
      profile = JSON.parse(response.to_str)
      Rails.logger.info profile["id"]
      #puts profile["name"]
      #puts profile["email"]
      #puts Date.parse profile["birthday"]
      Rails.logger.info profile["gender"].nil? ? 'null gender' : profile["gender"]
      User.new(
        :name => profile["name"], 
        :email => profile["email"], 
        :born_on => Date.parse(profile["birthday"]), 
        :gender => profile["gender"],
        :slug => profile["email"].split("@")[0]
      )
    else
      Rails.logger.error response.to_str
      return nil
    end
  end
end
