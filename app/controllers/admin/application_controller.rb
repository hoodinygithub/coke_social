class Admin::ApplicationController < ApplicationController
  layout "admin"
  skip_before_filter :do_basic_http_authentication
  skip_before_filter :login_required

  private
  def do_basic_http_authentication
    authenticate_or_request_with_http_basic do |username, password|
      username == "hoodiny" && password == "3057227000"
    end
  end
end