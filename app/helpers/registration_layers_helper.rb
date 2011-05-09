module RegistrationLayersHelper  
  def onclick_to_with_gat_code(url, code)
    "Base.utils.redirect_layer_to('#{url}', '#{code}', event)"
  end
  
  def gat_code(code)
    "pageTracker._trackPageview('#{code}');"    
  end
  
  def layer_background_image
    # "cyloop/#{(rand(10) + 1)}.jpg"
    "#{current_site.code.to_s}/1.jpg"
  end

  def registered_link_to(text, params)
    options = {}
    [:class, :title].each do |i|
      options[i] = params.delete(i)
    end
    
    link_to text, new_user_path(params), options
  end

end
