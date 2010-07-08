namespace :db do
  namespace :output do
    desc "Output Coke Top Artists Feed"
    task :coke_top_artists_feed => :environment do
      include Timebox

      feed = 'top_artists'
      output_path = ENV.has_key?('xml_output_path') ? ENV['xml_output_path'] : '/shared/common_coke/system/db/xml'

      Site.all(:conditions => "code like 'coke%'").each do |site|
        timebox "XML File Created to #{site.name}..." do
          write_rss_artist_feed(feed, site, output_path)
        end
      end
    end
    
    def image_exists?(url)
      require 'net/http'
      require 'uri'

      begin
        response = Net::HTTP.get_response URI.parse(url)
        if response.kind_of?(Net::HTTPSuccess)
          true
        elsif response.kind_of?(Net::HTTPNotFound)
          false
        end
      rescue 
        false
      end
    end    

    def write_rss_artist_feed(feed, site, path)
      limit = 70
      return if site.nil?
      items = site.top_artists(:limit => limit)
      return if items.empty?
      
      count = items.size

      file = File.open("#{path}/#{site.code}/top_artists_#{site.code}.xml", 'w')

      xml = Builder::XmlMarkup.new(:target => file, :indent => 2)

      xml.instruct! :xml, :version => "1.0"

      xml.items do
        items.each do |artist|
          title = "#{artist.name}"
          link =  CGI::escape("http://#{site.domain}/search/playlists/#{artist.name}")
          thumbnail   = AvatarsHelper.avatar_path(artist, :small) #s.artist.avatar_file_name.nil? ? "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/#{s.artist_id}/image/thumbnail/x46b.jpg" : s.artist.avatar_file_name.sub(/hires/,'thumbnail')
          large_image = AvatarsHelper.avatar_path(artist, :medium)  #s.artist.avatar_file_name.nil? ? "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/#{s.artist_id}/image/hi-thumbnail/x46b.jpg" : s.artist.avatar_file_name.sub(/hires/,'hi-thumbnail')

          unless image_exists?(thumbnail)
            #thumbnail = "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/404/image/thumbnail/default_image.jpg"
            thumbnail = "http://#{site.domain}/avatars/missing/artist.gif"
          end
          
          unless image_exists?(large_image)
            large_image = "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/404/image/hi-thumbnail/default_image.jpg"
          end          

          xml.item do
            xml.thumb thumbnail
            xml.detail ""
            xml.link link
            xml.dynamicReflection false
            xml.description title
          end
        end
        if count < limit
          chunks = (limit - count) / count
          the_rest = limit % count
          chunks.times do 
            items.each do |artist|
              title = "#{artist.name}"
              link =  CGI::escape("http://#{site.domain}/search/playlists/#{artist.name}")
              thumbnail = AvatarsHelper.avatar_path(artist, :small) #s.artist.avatar_file_name.nil? ? "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/#{s.artist_id}/image/thumbnail/x46b.jpg" : s.artist.avatar_file_name.sub(/hires/,'thumbnail')
              large_image = AvatarsHelper.avatar_path(artist, :medium)  #s.artist.avatar_file_name.nil? ? "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/#{s.artist_id}/image/hi-thumbnail/x46b.jpg" : s.artist.avatar_file_name.sub(/hires/,'hi-thumbnail')

              xml.item do
                xml.thumb thumbnail
                xml.detail ""
                xml.link link
                xml.dynamicReflection false
                xml.description title
              end
            end
          end
          
          if the_rest > 0
            items[0..the_rest - 1].each do |artist|
              title = "#{artist.name}"
              link =  CGI::escape("http://#{site.domain}/search/playlists/#{artist.name}")
              thumbnail = AvatarsHelper.avatar_path(artist, :small) #s.artist.avatar_file_name.nil? ? "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/#{s.artist_id}/image/thumbnail/x46b.jpg" : s.artist.avatar_file_name.sub(/hires/,'thumbnail')
              large_image = AvatarsHelper.avatar_path(artist, :medium)  #s.artist.avatar_file_name.nil? ? "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/#{s.artist_id}/image/hi-thumbnail/x46b.jpg" : s.artist.avatar_file_name.sub(/hires/,'hi-thumbnail')

              xml.item do
                xml.thumb thumbnail
                xml.detail ""
                xml.link link
                xml.dynamicReflection false
                xml.description title
              end
            end          
          end
        end
      end
    end
  end
end
