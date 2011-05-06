namespace :set_playlist_default_avatar do
  desc "Sets default avatars for playlists that don't have it defined"
  task :create => :environment do
    
    records = Playlist.count(:conditions => 'avatar_file_name IS NULL')

    0.step(records, 1000) do |offset|
      puts "** offset: #{offset}/records: #{records}"
      Playlist.all(:conditions => 'playlists.avatar_file_name IS NULL AND songs.deleted_at IS NULL AND albums.avatar_file_name IS NOT NULL', :offset => 0, :limit => 10, :order => 'id DESC', :include => {:songs => :album}, :joins => [:owner, {:songs => :album}]).each do |playlist|
        if playlist.valid?
          puts "SET DEFAULT AVATAR FOR: #{playlist.name} id #{playlist.id} WITH #{playlist.songs.first.album.avatar_file_name}"
          playlist.set_default_image(playlist.songs.first.album)
          playlist.save!
        end
      end
    end
  end
end
