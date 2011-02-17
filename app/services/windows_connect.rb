require "rest_client"
require "cgi"

class WindowsConnect
  settings = YAML.load_file("#{RAILS_ROOT}/config/windows_connect.yml")[RAILS_ENV]

  CLIENT_ID = settings['client_id']
  SECRET = settings['secret']

  TOKEN_URL = "https://consent.live.com/AccessToken.aspx"
  TOKEN_PARAMS = { :wrap_client_id => CLIENT_ID, :wrap_client_secret => SECRET, :idtype => 'PWID' }

  API_URL = "https://apis.live.net"

  def self.parse(p_wrap_verification_code, p_request, p_cookies, p_callback)
    Rails.logger.info p_wrap_verification_code
    params = TOKEN_PARAMS.merge :wrap_verification_code => p_wrap_verification_code, :wrap_callback => p_callback
    Rails.logger.info params.inspect
    Rails.logger.info TOKEN_URL
    response = begin
      RestClient.post TOKEN_URL, params
    rescue => e
      Rails.logger.info e.inspect
      Rails.logger.info e.response
      Rails.logger.info e.response.description
      nil
    end
    Rails.logger.info response.description
    Rails.logger.info response.headers.inspect
    Rails.logger.info response.to_s

    if response.code == 200
      response_params = CGI::parse(response.to_s)

      access_token = response_params['wrap_access_token']
      Rails.logger.info 'access_token: ' + access_token

      # idtype=PWID gets the old Windows Live ID
      wlid = response_params['uid']
      Rails.logger.info 'WLID: ' + wlid

      expires = response_params['wrap_access_token_expires_in']
      Rails.logger.info 'expires: ' + expires

      #wrap_refresh_token = response_params['wrap_refresh_token']
      #Rails.logger.info 'refresh_token'
      #Rails.logger.info wrap_refresh_token

      #skey = response_params['skey']
      #Rails.logger.info 'skey'
      #Rails.logger.info skey

      #p_cookies[:c_clientId] = CLIENT_ID
      #p_cookies[:c_accessToken] = wrap_access_token
      #p_cookies[:c_expiry] = wrap_access_token_expires_in
      #p_cookies[:lca] = "done"

      u = User.find_by_msn_live_id(wlid)
      if u.nil?
        # Repeat the process with idtype removed to get the new Windows Connect ID
      else
        # Get the Windows Connect ID and upgrade user 'u'.
      end
      # Reverse this.  Get the new ID first.  If not found, get the old ID.  If not found, use the new id.
    else
      Rails.logger.error response.inspect
      return nil
    end
  end
end
