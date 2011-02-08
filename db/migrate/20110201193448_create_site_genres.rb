class CreateSiteGenres < ActiveRecord::Migration
  def self.up
    create_table :site_genres do |t|
      t.references :site ,:null=>false
      t.references :genre, :null=>false
      t.timestamps
    end
    add_index(:site_genres, :site_id)
    add_index(:site_genres, :genre_id)
    add_index(:site_genres, [:site_id, :genre_id], :unique => true)
    styles=["Alternativa","Anglo","Balada","Blues","Cumbia","Electronica","Funk","Hip Hop","Jazz","Latina","Pop","Punk","R&B","Rap","Reggae","Rock","Romantica","Reggaeton","Soul"]
    site= Site.find_by_code('cokear')
    styles.each { |st| 
      genre=Genre.find_by_name(st)
      genre = Genre.create(:name => st, :key=>"genre_#{st.downcase}", :top=>false) if genre.nil?
      SiteGenre.create(:site_id => site.id, :genre_id => genre.id)
    }
    site= Site.find_by_code('cokemx')
    styles.each { |st| 
      genre=Genre.find_by_name(st)
      genre = Genre.create(:name => st, :key=>"genre_#{st.downcase}", :top=>false) if genre.nil?
      SiteGenre.create(:site_id => site.id, :genre_id => genre.id)
    }
    site= Site.find_by_code('cokelatam')
    styles.each { |st| 
      genre=Genre.find_by_name(st)
      genre = Genre.create(:name => st, :key=>"genre_#{st.downcase}", :top=>false) if genre.nil?
      SiteGenre.create(:site_id => site.id, :genre_id => genre.id)
    }
    site= Site.find_by_code('cokebr')
    more_styles=["Alternativa","Anglo","Balada","Blues","Cumbia","Electronica","Funk","Hip Hop","Jazz","Latina","Pop","Punk","R&B","Rap","Reggae","Rock","Romantica","Reggaeton","Soul","Brega","Choro","Samba","Bossa-Nova","Topicalisimo","Musica de Pará","Baião","Pagode","Maracatu","Frevo","Forró","Ciranda","Lambada","Salsa"]
    more_styles.each { |st| 
      genre=Genre.find_by_name(st)
      genre = Genre.create(:name => st, :key=>"genre_#{st.downcase}", :top=>false) if genre.nil?
      SiteGenre.create(:site_id => site.id, :genre_id => genre.id)
    }
    
  end

  def self.down
    drop_table :site_genres
  end
end
