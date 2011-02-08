require 'open-uri'

namespace :artist_index do
  desc "Create index_bands"
  task :create => :environment do

    def cache_html(domain, query, app_path)
      puts "http://#{domain}/artists/list/#{query}"
      open("http://#{domain}/artists/list/#{query}", :http_basic_authentication=>['happiness', 'd0ral8725'] ) { |page|
        puts "-> /shared/#{app_path}/artist_index/#{query}.html"
        File.open("/shared/#{app_path}/artist_index/#{query}.html", 'w') { |file| file.write(page.read) }
      }
    end

    Site.all(:conditions=>"code LIKE 'coke%'").each { |site|
      puts site.domain
      puts RAILS_ENV
      domain = RAILS_ENV=="development" ? "localhost:3000" : site.domain

      # Convert site_code to app_path.  Why is this different?
      app_path = case site.code
      when 'cokear' then 'coke_ar'
      when 'cokebr' then 'coke_brazil'
      when 'cokelatam' then 'coke_latam'
      when 'cokemx' then 'coke_mx'
      else raise "Unknown site code #{site.code}"
      end
      puts app_path

      "A".upto("Z") { |letter|
        cache_html(domain, letter, app_path)
      }
      0.upto(9) { |number| 
        cache_html(domain, number, app_path)
      }
      cache_html(domain, "special", app_path)
    }
    
  end 
end
