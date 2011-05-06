namespace :set_playlist_default_avatar do
  desc "Sets default avatars for playlists that don't have it defined"
  task :create => :environment do
    
    records = Playlist.count(:select => "distinct(playlists.id)", :conditions => 'playlists.avatar_file_name IS NULL AND songs.deleted_at IS NULL AND albums.avatar_file_name IS NOT NULL', :joins => [:owner, {:songs => :album}])

    0.step(records, 1000) do |offset|
      puts "** offset: #{offset}/records: #{records}"
      Playlist.all(:conditions => 'playlists.avatar_file_name IS NULL AND songs.deleted_at IS NULL AND albums.avatar_file_name IS NOT NULL', :offset => offset, :limit => 1000, :order => 'playlists.id DESC', :include => {:songs => :album}, :joins => [:owner, {:songs => :album}]).each do |playlist|
        if playlist.valid?
          art_song = nil
          playlist.songs.each { |song|
            if song.album.avatar_file_nam
              art_song = song
              break;
            end
          }

          if art_song
            puts "SET DEFAULT AVATAR FOR: #{playlist.name} id #{playlist.id} WITH #{art_song.album.avatar_file_name}"
            playlist.set_default_image(art_song.album)
            playlist.save!
          end
        end
      end
    end
  end
end
