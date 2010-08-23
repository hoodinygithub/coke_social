class Admin::ApplicationController < ApplicationController
  layout "admin"
<<<<<<< HEAD
  before_filter :admin_only_in_english
=======
  skip_before_filter :do_basic_http_authentication
>>>>>>> Valid tags - Work in progress
  skip_before_filter :login_required

  private
  def do_basic_http_authentication
    authenticate_or_request_with_http_basic do |username, password|
      username == "hoodiny" && password == "3057227000"
    end
  end
  
  def admin_only_in_english
    I18n.locale = :en
  end
end