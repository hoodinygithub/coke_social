namespace :db do
  namespace :output do
    desc "Output Coke Top Artists Feed"
    task :coke_top_artists_feed => :environment do
      include Timebox

      feed = 'top_artists'
      output_path = ENV.has_key?('xml_output_path') ? ENV['xml_output_path'] : '/shared/common_coke/system/db/xml'

      size = 35

      Site.all(:conditions => "code like 'coke%'").each do |site|
        timebox "XML File Created to #{site.name}..." do
          write_rss_artist_feed(feed, site, output_path, size)
        end
      end
    end

    def write_rss_artist_feed(feed, site, path, limit)
      duplicate = 1 # starts at 0 index
      return if site.nil?
      items = site.top_artists.all(:limit => limit)
      return if items.empty?

      file = File.open("#{path}/#{site.code}/top_artists_#{site.code}.xml", 'w')

      xml = Builder::XmlMarkup.new(:target => file, :indent => 2)

      xml.instruct! :xml, :version => "1.0"
      xml.items do
        (0..duplicate).each do |c|
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
      end
    end
  end
end
