# %w(rest_client cgi json).each { |lib| require lib }

class WindowsConnect
  settings = YAML.load_file("#{RAILS_ROOT}/config/windows_connect.yml")[RAILS_ENV]

  CLIENT_ID = settings['client_id']
  SECRET = settings['secret']

  TOKEN_URL = "https://consent.live.com/AccessToken.aspx"
  TOKEN_PARAMS = { :wrap_client_id => CLIENT_ID, :wrap_client_secret => SECRET }
  WLID_TOKEN_PARAMS = TOKEN_PARAMS.merge :idtype => 'PWID'

  # http[s]://[LocatorID.]apis.live.net/V<Version>/cid-<CID>/<ResourceName>/<CollectionName>/<ID>
  # ex. http://sn1.apis.live.net/V4.1/cid-C3092E04172BA9C3/Contacts/AllContacts
  API_PROFILES_URL = "https://apis.live.net/V4.1/cid-%s/Profiles"
  API_PROFILES_URL_HEADERS = {"Accept" => "application/json"}

  #
  # Parse Windows Connect verification into a User
  #
  def self.parse_verification_code(p_wrap_verification_code, p_callback)
    params = TOKEN_PARAMS.merge :wrap_verification_code => p_wrap_verification_code, :wrap_callback => p_callback
    response = get_access_token(TOKEN_URL, params)

    if response.code == 200
      response_params = CGI::parse(response.to_s)

      access_token = response_params['wrap_access_token'][0].to_s
      cid = response_params['uid'][0].to_s
      #expires = response_params['wrap_access_token_expires_in'][0].to_s
      #wrap_refresh_token = response_params['wrap_refresh_token']
      #skey = response_params['skey']

      Rails.logger.info 'access_token: ' + access_token
      Rails.logger.info 'cid: ' + cid
      #Rails.logger.info 'expires: ' + expires
      #Rails.logger.info 'refresh token: ' + wrap_refresh_token
      #Rails.logger.info 'secret key: ' + skey

      # Get profile data
      auth_headers = API_PROFILES_URL_HEADERS.merge "Authorization" => access_token
      response = get_profile((API_PROFILES_URL % cid.to_s), auth_headers)
      # Supports multiple profiles per user.  Don't know what that means, so select the 1st one.
      response_profile = JSON::parse(response)['Entries'][0]
      
      # Gender: 0 = male, 1 = female (I'm guessing.)
      gender = (response_profile['Gender'] == 0 ? 'Male' : 'Female')
      Rails.logger.info 'gender: ' + gender
      # Supports multiple email "Types".  Don't know what that means, so select the 1st one.
      email = response_profile['Emails'][0]['Address']
      Rails.logger.info 'email: ' + email

      # Where the f is the name?      
      user = User.new(
      	:email => email,
      	:gender => gender,
      	:slug => email.split("@")[0],
      	:sso_windows => cid
      )
      Rails.logger.info user.inspect

      cid_user = User.find_by_sso_windows_and_deleted_at(cid, nil)
      if cid_user
        # User found by CID.
        return cid_user
      else
        # Not found with CID.  Try with old PWID.
        params.merge! :idtype => 'PWID'
        response = get_access_token(TOKEN_URL, params)

        if response.code == 200
          response_params = CGI::parse(response.to_s)
          access_token = response_params['wrap_access_token'][0]
          wlid = response_params['uid'][0]
          expires = response_params['wrap_access_token_expires_in'][0]

          return User.find_by_msn_live_id_and_deleted_at(wlid, nil)
        else
          Rails.logger.error response.inspect
          return nil
        end
      end
    else
      Rails.logger.error response.inspect
      return nil
    end
  end

  private

  #
  # POST request for the access token and user id
  #
  def self.get_access_token(p_url, p_params) 
    Rails.logger.info "POST " + p_url
    Rails.logger.info p_params.inspect
    response = RestClient.post p_url, p_params
    Rails.logger.info response.to_s
    response
  end
  
  # 
  # GET request for profile data
  #
  def self.get_profile(p_url, p_headers)
    Rails.logger.info "GET " + p_url
    Rails.logger.info p_headers.inspect
    response = RestClient.get p_url, p_headers
    Rails.logger.info response.to_s
    response
  end
end
