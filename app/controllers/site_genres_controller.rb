class SiteGenresController < ApplicationController
  def list
    @site_genres= SiteGenre.all(:conditions=>{:site_id=>current_site.id}, :include=>:genre)
    @site_genres=@site_genres.sort_by{|site| site.genre.name}
    render :layout => "logged_out"
  end
end
