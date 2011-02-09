# Allow the metal piece to run in isolation
# require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class PersonalizeJavascript
  def self.call(env)
    if env["PATH_INFO"] =~ /^\/logged_in.js/
      request   = Rack::Request.new(env)
      session   = env['rack.session']
      host_port = (request.port.to_s == "80") ? "#{request.host}" : "#{request.host}:#{request.port}"
      if session && session[:coke_user_id]
        params    = request.params
        # Coke has this in the drop down menu.  Instead, just empty out the div
        # logout_url = params['logout_url'] ? "<a href='#{params['logout_url']}'>#{I18n.t("sessions.destroy.sign_out").strip}<\/a>" : ""
        logout_url = ""
        I18n.default_locale = params['lang'].to_sym rescue :en
        begin
          current_user = User.find(session[:coke_user_id])
          avatar_img_path = AvatarsHelper.avatar_path(current_user, :tiny)
          avatar_img_filename = avatar_img_path.split("/").last.split("?").first
          js = <<-END
          jQuery(document).ready(function($){
            $('#login_register_links').html("#{logout_url}");
            $('#userdata_box .user_name').text("#{current_user.try(:first_name)}");
            $('#userdata_box .avatar').attr("src", "#{avatar_img_path}");
            $('#userdata_box .avatar').attr("alt", "#{avatar_img_filename}");
            $('#userdata_box').removeClass("user_data_logged_out").addClass("user_data_logged_in");
          });
          END
        rescue ActiveRecord::RecordNotFound
          # Account not found
          js = ""
        end
        [200, {"Content-Type" => "text/javascript; charset=utf-8", "Cache-Control" => "no-cache", "Expires" => "-1"}, [js.gsub("\n", ' ')]]
      else
        [200, {"Content-Type" => "text/html", "Cache-Control" => "no-cache", "Expires" => "-1"}, ['']]
      end
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end
