class RecEngine::ArtistFromPlaylist < RecEngine::Abstract
  # Example artist amg id: "P   440673"

  integer_reader :artist_id, :album_id
  reader :image, :folder_name, :artist, :artist_amg_id
  
  def slug
    folder_name
  end

  def album_image
    image
  end
  
  alias to_param slug

  def avatar
    @avatar ||= OpenStruct.new(:url => asset_url_rec(image))
  end

  def to_s
    artist
  end
  
end
