class RecEngine::SimilarArtist < RecEngine::Abstract
  # Example artist amg id: "P     5241"
  
  integer_reader :id
  reader :artist_name, :profile_url, :image

  def slug
    profile_url.sub(/^\//, '')
  end
  
  def artist_id
    image.match(/usr\/(\d+)\/image/)[1] rescue nil
  end

  alias to_param slug

  def avatar
    require 'ostruct'
    OpenStruct.new(:url => "#{ENV['ASSETS_URL']}#{image}")
  end

end
