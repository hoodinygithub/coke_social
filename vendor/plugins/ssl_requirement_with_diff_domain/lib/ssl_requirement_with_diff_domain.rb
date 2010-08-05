# Copyright (c) 2005 David Heinemeier Hansson
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
module SslRequirementWithDiffDomain
  def self.included(controller)
    controller.extend(ClassMethods)
    controller.before_filter(:ensure_proper_protocol)
  end

  module ClassMethods
    def ssl_required_object(obj)
      write_inheritable_attribute(:ssl_required_obj, obj)
    end
    
    # Specifies that the named actions requires an SSL connection to be performed (which is enforced by ensure_proper_protocol).
    def ssl_required_with_diff_domain(*actions)
      write_inheritable_array(:ssl_required_actions, actions)
    end

    def ssl_allowed_with_diff_domain(*actions)
      write_inheritable_array(:ssl_allowed_actions, actions)
    end
  end
  
  protected
    # Overwrite a common method
    def redirect_back_or_default(default)
      # Check path in :return_to
      domain = ssl_domain(request.ssl?)
      path   = domain.gsub(domain.split("/").first, "")
      return_to = if path && !path.empty?
        if !request.ssl? && session[:return_to] =~ Regexp.new("^#{path}")
          logger.info "[DEBUG] With path"
          session[:return_to].gsub(path, "")
        elsif request.ssl? && !(session[:return_to] =~ Regexp.new("^#{path}"))
          logger.info "[DEBUG] No Path With path"          
          "#{path}/#{session[:return_to]}"
        end
      end
      logger.info "[DEBUG] #{return_to} - #{session[:return_to]}"
      redirect_to(return_to || session[:return_to] || default)
      session[:return_to] = nil
    end
    
    def request_ssl?
      if Rails.env.development?
        request.host == ssl_site.ssl_domain.split(":").first
      else
        request.ssl?
      end
    end
  
    # Returns true if the current action is supposed to run as SSL
    def ssl_required?
      (self.class.read_inheritable_attribute(:ssl_required_actions) || []).include?(action_name.to_sym)
    end
    
    def ssl_allowed?
      (self.class.read_inheritable_attribute(:ssl_allowed_actions) || []).include?(action_name.to_sym)
    end
    
    def ssl_site
      self.send(self.class.read_inheritable_attribute(:ssl_required_obj).to_sym)
    end
    
    def ssl_domain(secure=true)            
      if secure
        ssl_site.ssl_domain
      else
        ssl_site.domain || request.host
      end
    rescue Exception => ex
      logger.fatal ex.message
      logger.fatal ".......#{ex.backtrace.join("\n.......")}"
      request.host
    end                                
    
    def ssl_request_uri(secure=true)
      domain = ssl_domain(!secure)
      path   = domain.gsub(domain.split("/").first, "")
      request.request_uri.gsub(path, "")
    rescue Exception => ex
      logger.fatal ex.message
      logger.fatal ".......#{ex.backtrace.join("\n.......")}"
      request.request_uri
    end
    
    def ssl_protocol
      if Rails.env.development?
        "http://"
      else
        if request.ssl?
          "http://"
        else
          "https://"
        end
      end 
    end

  private
    def ensure_proper_protocol
      return true if ssl_allowed?

      if ssl_required? && !request_ssl?
        logger.info "[DEBUG] SSL: true - request: false - referer: #{request.env['HTTP_REFERER']} - request: #{request.request_uri} - controller: #{controller_name}##{action_name} - xhr: #{request.xhr?}" 
        redirect_to(ssl_protocol + ssl_domain + ssl_request_uri)
        flash.keep
        return false
      elsif request_ssl? && !ssl_required?
        logger.info "[DEBUG] SSL: false - request: true - referer: #{request.env['HTTP_REFERER']} - request: #{request.request_uri} - controller: #{controller_name}##{action_name} - xhr: #{request.xhr?}"        
        redirect_to(ssl_protocol + ssl_domain(false) + ssl_request_uri(false))
        flash.keep
        return false
      else
        logger.info "[DEBUG] Nothing - referer: #{request.env['HTTP_REFERER']} - request: #{request.request_uri} - controller: #{controller_name}##{action_name} - xhr: #{request.xhr?}"
      end
    end
end
