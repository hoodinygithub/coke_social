namespace :db do
  namespace :output do
    desc "Output Coke Top Artists"
    task :xml_top_artists => :environment do
      include Timebox

      feed = 'top_artists'
      output_path = 'public'

      size = 100

      Site.all(:conditions => "code like '%coke%'").each do |site|
        timebox "XML File Created to #{site.name}..." do
          write_rss_artist_feed(feed, site, output_path, size)
        end
      end
    end

    def write_rss_artist_feed(feed, site, path, limit)
      return if site.nil?
      items = site.summary_top_artists.limited_to(limit)
      return if items.empty?

      file = File.open("#{RAILS_ROOT}/#{path}/top_artists_#{site.code}.xml", 'w')

      xml = Builder::XmlMarkup.new(:target => file, :indent => 2)

      xml.instruct! :xml, :version => "1.0"
      xml.items do
        items.each do |s|
          
          title = "#{s.artist.name}"
          link = "http://#{site.domain}/#{s.artist.slug}"
          thumbnail = s.artist.avatar_file_name.nil? ? "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/#{s.artist_id}/image/thumbnail/x46b.jpg" : s.artist.avatar_file_name.sub(/hires/,'thumbnail')
          large_image = s.artist.avatar_file_name.nil? ? "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/#{s.artist_id}/image/hi-thumbnail/x46b.jpg" : s.artist.avatar_file_name.sub(/hires/,'hi-thumbnail')

          xml.item do
            xml.thumb thumbnail
            xml.detail large_image
            xml.link link
            xml.description title
            xml.dynamicReflecton false
          end
        end
      end
    end
  end
end
