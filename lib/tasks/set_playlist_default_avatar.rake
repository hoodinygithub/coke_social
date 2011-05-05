namespace :set_playlist_default_avatar do
  desc "Sets default avatars for playlists that don't have it defined"
  task :create => :environment do
    
    records = Playlist.count(:conditions => 'avatar_file_name IS NULL')

    0.step(records, 10000) do |offset|
      puts "** offset: #{offset}/records: #{records}"
      Playlist.all(:conditions => 'avatar_file_name IS NULL', :offset => offset, :limit => 10000, :order => 'id DESC', :include => {:songs => :album}).each do |playlist|
        unless playlist.songs.first.nil? or playlist.songs.first.album.avatar_file_name.nil? or playlist.invalid?
          puts "SET DEFAULT AVATAR FOR: #{playlist.name} id #{playlist.id} WITH #{playlist.songs.first.album.avatar_file_name}"
          playlist.set_default_image(playlist.songs.first.album)
          playlist.save!
        end
      end
    end
  end
end
