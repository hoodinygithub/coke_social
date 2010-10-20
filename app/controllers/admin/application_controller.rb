class Admin::ApplicationController < ApplicationController
  layout "admin"
  before_filter :admin_only_in_english
  skip_before_filter :login_required
  before_filter :do_basic_http_authentication

  private
  def do_basic_http_authentication
    authenticate_or_request_with_http_basic do |username, password|
      username == "happiness" && password == "d0ral8725"
    end
  end
    
  def admin_only_in_english
    I18n.locale = :en
  end
end
