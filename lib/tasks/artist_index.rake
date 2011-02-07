require 'open-uri'

namespace :artist_index do
  desc "Create aindex_bands"
  task :create => :environment do
    puts ApplicationController.current_site.id
    Site.all(:conditions=>"code LIKE 'coke%'").each { |site|
      puts site.domain
      puts RAILS_ENV
      domain = RAILS_ENV="development" ? "localhost:3000" : site.domain

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
        puts "http://#{domain}/artists/list/#{letter}"
        open("http://#{domain}/artists/list/#{letter}", :http_basic_authentication=>['happiness', 'd0ral8725'] ) { |page|
          puts "-> /shared/#{app_path}/artist_index/"
          File.open("/shared/#{app_path}/artist_index/#{letter}.html", 'w') { |file| file.write(page.read) }
        }
      }
      0.upto(9) { |number| 
        puts "http://#{domain}/artists/list/#{number}"
        open("http://#{domain}/artists/list/#{number}", :http_basic_authentication=>['happiness', 'd0ral8725'] ) { |page|
          puts "-> /shared/#{app_path}/artist_index/"
          File.open("/shared/#{app_path}/artist_index/#{number}.html", 'w') { |file| file.write(page.read) }
        }
      }
      open("http://#{domain}/artists/list/special", http_basic_authentication=>['happiness', 'd0ral8725'] ) { |page|
          puts "-> /shared/#{app_path}/artist_index/"
          File.open("/shared/#{app_path}/artist_index/special.html", 'w') { |file| file.write(page.read) }
        }
      }
    }

  end 
end
