class AddNamesToEmptyStringPlaylists < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      UPDATE playlists SET name = concat('playlist-', id) WHERE name IS NOT NULL AND char_length(name) = 0;
    SQL
  end

  def self.down
    puts "Irreversible update, but I ain't mad at 'cha"
  end
end
