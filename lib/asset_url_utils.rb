module AssetUrlUtils
  # Convert a db avatar_file_name into a URL
  def asset_url p_path
    add_prefix p_path[18..-1]
  end

  # Convert a rec engine image path into a URL
  def asset_url_rec p_path
    add_prefix p_path[44..-1]
  end

  private
  def add_prefix p_path
    ENV['ASSETS_URL'] + "/" + p_path[1].chr + "/" + p_path[2].chr + "/" + p_path[3].chr + p_path
  end
end

