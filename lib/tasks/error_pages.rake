namespace :error_pages do
  desc "Clear all error pages"
  task :clear do
    paths = [
      File.join(RAILS_ROOT, "public", "500*.html"),
      File.join(RAILS_ROOT, "public", "404*.html"),
      
    ]
    
    paths.each {|p| system("rm #{p}")}
  end
  
  desc "Create static errors page from template"
  task :create do
    require 'yaml'
    translate_keys_fp = File.join(RAILS_ROOT, 'config', 'locales', 'static.yml')
    sites_fp = File.join(RAILS_ROOT, 'config', 'sites.yml')
    content = YAML::load_file(translate_keys_fp)['static']
    sites = YAML::load_file(sites_fp)
    template_content = File.open(File.join(RAILS_ROOT, 'public', 'errors.html')).read
    
    content.keys.each do |market|
      content[market].keys.each do |error|
        file_fp = File.join(RAILS_ROOT, 'public', 'errors', "#{error}_#{market}.html")
        if File.exist? file_fp
          title = content[market][error]['page_title'] rescue ""

          site_url = ""
          sites.each do |key, value|
            site_url = value['domains'].first if value['code'] == market
          end
          
          error_content = File.open(file_fp).read
          begin
            final_content = template_content.gsub("{{ CONTENT }}", error_content)
            final_content = final_content.gsub("{{ TITLE }}", title)
            final_content = final_content.gsub("{{ URL }}", site_url)
          rescue
            puts "Error #{$!}"
          end
          
          target = File.join(RAILS_ROOT, 'public', "#{error}_#{market}.html")
          puts "Saving #{target}"
          File.open(target, "w") do |f|
            f.write(final_content)
          end
        end
      end
    end
  end
end
