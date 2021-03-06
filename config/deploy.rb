# For complete deployment instructions, see the following support guide:
# http://www.engineyard.com/support/guides/deploying_your_application_with_capistrano

require "eycap/recipes"
require 'new_relic/recipes'
require 'tinder'

# =================================================================================================
# ENGINE YARD REQUIRED VARIABLES
# =================================================================================================
# You must always specify the application and repository for every recipe. The repository must be
# the URL of the repository you want this recipe to correspond to. The :deploy_to variable must be
# the root of the application.

set :keep_releases,       5
set :application,         ENV['DEPLOY_SITE'] || ARGV[0]
set :deploy_base,         "/data"
set :shared_base,         "/shared"
set :user,                "hoodiny"
set :password,            "Xh00d17ME71z"
set :deploy_to,           "#{deploy_base}/#{application}"
#set :monit_group,         "unicorn_#{ENV['DEPLOY_SITE'] || ARGV[0]}"
set :runner,              "hoodiny"
set :repository,          "git@github.com:hoodinygithub/coke_social.git"
set :cyqueue,             "/data/cyqueue/current"

set :git_shallow_clone,   1

set :scm,                 :git
set :real_revision, 			lambda { source.query_revision(revision) { |cmd| capture(cmd) } }
set :production_database, "cyloop_production"
set :production_dbhost,   "cyloop-db-new_enzo"
set :staging_database,    "cyloop_staging"
set :staging_dbhost,      "cyloop-db-new_enzo"
set :dbuser,              "hoodiny_db"
set :dbpass,              "Q97t42WGDj8a"

set :shared_path,         "#{deploy_to}/shared"
set :sites,               ["coke_brazil", "coke_latam", "coke_ar", "coke_mx"]


# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false

# =================================================================================================
# ROLES
# =================================================================================================
# You can define any number of roles, each of which contains any number of machines. Roles might
# include such things as :web, or :app, or :db, defining what the purpose of each machine is. You
# can also specify options that can be used to single out a specific subset of boxes in a
# particular role, like :primary => true.

set :branch, "console_upgrade"

# Production
task :production do
  role :web, "72.46.233.77:7001"
  role :app, "72.46.233.77:7001", :memcached => true, :sphinx => true
  role :db , "72.46.233.77:7001", :primary => true
  role :app, "72.46.233.77:7003", :memcached => true, :sphinx => true

  set :rails_env, "production"
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
end


# Brazil
task :coke_brazil do
  role :web, "72.46.233.77:7001"
  role :app, "72.46.233.77:7001", :memcached => true, :sphinx => true
  role :db , "72.46.233.77:7001", :primary => true
  role :app, "72.46.233.77:7003", :memcached => true, :sphinx => true

  set :rails_env, "production"
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
end

# Latam
task :coke_latam do
  role :web, "72.46.233.77:7001"
  role :app, "72.46.233.77:7001", :memcached => true, :sphinx => true
  role :db , "72.46.233.77:7001", :primary => true
  role :app, "72.46.233.77:7003", :memcached => true, :sphinx => true

  set :rails_env, "production"
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
end

task :staging do
  role :web, "72.46.233.74:7000"
  role :app, "72.46.233.74:7000", :memcached => true, :sphinx => true
  role :db , "72.46.233.74:7000", :primary => true

  set :rails_env, "staging"
  set :environment_database, defer { staging_database }
  set :environment_dbhost, defer { staging_dbhost }
end

desc "Create all remaining symlinks"
task :symlink_remaining, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
  run <<-CMD
    rm -rf #{latest_release}/db/sphinx &&
    mkdir -p #{latest_release}/db/ &&
    ln -s #{shared_path}/system/db/sphinx #{latest_release}/db/sphinx &&
    rm #{latest_release}/config/memcached.yml &&
    ln -s #{shared_path}/config/memcached.yml #{latest_release}/config/memcached.yml &&
    ln -s #{shared_path}/config/passenger_cluster.yml #{latest_release}/config/passenger_cluster.yml &&
    ln -s #{shared_path}/config/resque.yml #{latest_release}/config/resque.yml &&
    ln -s #{shared_path}/system/db/xml/cokebr/top_artists_cokebr.xml #{latest_release}/public/feeds/top_artists_cokebr.xml &&
    ln -s #{shared_path}/system/db/xml/cokelatam/top_artists_cokelatam.xml #{latest_release}/public/feeds/top_artists_cokelatam.xml &&
    ln -s #{shared_path}/system/db/xml/cokemx/top_artists_cokemx.xml #{latest_release}/public/feeds/top_artists_cokemx.xml &&
    ln -s #{shared_path}/system/db/xml/cokear/top_artists_cokear.xml #{latest_release}/public/feeds/top_artists_cokear.xml &&
    ln -s #{shared_path}/artist_index #{latest_release}/public/index-bands
  CMD

  if ['staging','production'].include?(rails_env)
    #db symlinks
    run <<-CMD
      rm -rf #{latest_release}/db/fixtures &&
      ln -s #{shared_path}/system/db/fixtures #{latest_release}/db/fixtures &&
      rm -rf #{latest_release}/db/geoip &&
      ln -s #{shared_path}/system/db/geoip #{latest_release}/db/geoip
    CMD
    
    site_code = case application 
      when 'coke_brazil' then
        'cokebr'
      when 'coke_latam' then
        'cokelatam'
      when 'coke_ar' then
        'cokear'
      else 
        'cokemx'
      end

    run <<-CMD
      rm -rf #{latest_release}/public/404.html && rm -rf #{latest_release}/public/422.html && rm -rf #{latest_release}/public/500.html && rm -rf #{latest_release}/public/400.html &&
      ln -s #{latest_release}/public/400_#{site_code}.html #{latest_release}/public/400.html &&            
      ln -s #{latest_release}/public/404_#{site_code}.html #{latest_release}/public/404.html &&
      ln -s #{latest_release}/public/422_#{site_code}.html #{latest_release}/public/422.html &&
      ln -s #{latest_release}/public/500_#{site_code}.html #{latest_release}/public/500.html &&
      rm #{latest_release}/public/robots.txt &&
      ln -s #{shared_path}/robots.txt #{latest_release}/public/robots.txt && 
      ln -s #{shared_path}/system/sitemap_style.xls #{latest_release}/public/sitemap_style.xls
    CMD
  end
end

#namespace :unicorn do
#  desc <<-DESC
#  Start the Unicorn Master.  This uses the :use_sudo variable to determine whether to use
#  sudo or not. By default, :use_sudo is set to true.
#  DESC
#  task :start, :roles => [:app], :except => {:unicorn => false} do
#    #sudo "/usr/bin/monit start all -g #{monit_group}"
#    #sudo "/usr/bin/monit start all -g #{monit_group}_ssl"
#  end
#
#  desc <<-DESC
#  Restart the Unicorn processes on the app server by starting and stopping the master.
#  This uses the :use_sudo variable to determine whether to use sudo or not. By default,
#  :use_sudo is set to true.
#  DESC
#  task :restart, :roles => [:app], :except => {:unicorn => false} do
#    #sudo "/usr/bin/monit restart all -g #{monit_group}"
#    #sudo "/usr/bin/monit restart all -g #{monit_group}_ssl"
#  end
#
#  desc <<-DESC
#  Stop the Unicorn processes on the app server.  This uses the :use_sudo
#  variable to determine whether to use sudo or not. By default, :use_sudo is
#  set to true.
#  DESC
#  task :stop, :roles => [:app], :except => {:unicorn => false} do
#    #sudo "/usr/bin/monit stop all -g #{monit_group}"
#    #sudo "/usr/bin/monit stop all -g #{monit_group}_ssl"
#  end
#
#  desc <<-DESC
#  Reloads the unicorn works gracefully - Use deploy task for deploys
#  DESC
#  task :reload, :roles => [:app], :except => {:unicorn => false} do
#    #sudo "/engineyard/bin/unicorn #{application} reload"
#    #sudo "/engineyard/bin/unicorn #{application}_ssl reload"
#  end
#
#  desc <<-DESC
#  Adds a Unicorn worker - Beware of causing your host to swap, this setting isn't permanent
#  DESC
#  task :aworker, :roles => [:app], :except => {:unicorn => false} do
#    #sudo "/engineyard/bin/unicorn #{application} aworker"
#    #sudo "/engineyard/bin/unicorn #{application}_ssl aworker"
#  end
#
#  desc <<-DESC
#  Removes a unicorn worker (gracefully)
#  DESC
#  task :rworker, :roles => [:app], :except => {:unicorn => false} do
#    #sudo "/engineyard/bin/unicorn #{application} rworker"
#    #sudo "/engineyard/bin/unicorn #{application}_ssl rworker"
#  end
#
#  desc <<-DESC
#  Deploys app gracefully with USR2 and unicorn.rb combo
#  DESC
#  task :deploy, :roles => [:app], :except => {:unicorn => false} do
#    #sudo "/engineyard/bin/unicorn #{application} deploy"
#    #sudo "/engineyard/bin/unicorn #{application}_ssl deploy" if rails_env != "staging" # ssl turned off in staging
#  end
#end #namespace

namespace :deploy do
  # Try and get around EY gem
  task :symlink_configs, :roles => :app, :except => {:no_release => true} do
    run <<-CMD
      cd #{latest_release} &&
      ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml
    CMD
  end

  task :symlink_cyqueue do
    run "ln -nfs #{cyqueue} #{latest_release}/vendor/cyqueue"
  end

  task :pre_announce do
    campfire_notification "#{ENV['USER']} is preparing to deploy #{application} to #{rails_env} (#{branch})"
  end

  task :post_announce do
    campfire_notification "#{ENV['USER']} finished deploying #{application} to #{rails_env} (#{branch})"
  end

  task :restart, :roles => :app do
    #unicorn.deploy
    run "touch #{latest_release}/tmp/restart.txt"
  end

  desc "Start the Unicorn processes on the app slices."
  task :start, :roles => :app do
    #unicorn.start
    run "touch #{latest_release}/tmp/restart.txt"
  end

  desc "Stop the Unicorn processes on the app slices."
  task :stop, :roles => :app do
    #unicorn.stop
    run "touch #{latest_release}/tmp/restart.txt"
  end

  task :save_current_branch do
    if rails_env == 'staging'    
      run "echo '#{application} - #{branch}' > #{shared_path}/current_branch.log"
      run "ln -s #{shared_base}/common_coke/deployments.txt #{latest_release}/public/deployments.txt"      
    end
  end
  
  task :build_release_html, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
    if rails_env == 'staging'
      deployments_file = "#{shared_base}/common_coke/deployments.txt"
      run "echo 'CURRENT STAGING BRANCHES' > #{deployments_file}"
      sites.each do |site| 
        run "cat #{shared_base}/#{site}/current_branch.log >> #{deployments_file}"
      end
    end
  end  
end

# =================================================================================================
# desc "Example custom task"
task :hoodiny_custom, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
  sudo <<-CMD
     /usr/bin/rake -f #{latest_release}/Rakefile gems:install RAILS_ENV=#{rails_env}
     /usr/bin/rake -f #{latest_release}/Rakefile sitemap:create RAILS_ENV=#{rails_env}
  CMD
end
#
# after "deploy:symlink_configs", "hoodiny_custom"
# =================================================================================================

#before "deploy:migrations", "deploy:pre_announce"
after "deploy:symlink_configs", "symlink_remaining" #,"symlink_sites"

# Do not change below unless you know what you are doing!
after "deploy", "deploy:cleanup"
after "deploy:migrations" , "deploy:cleanup"
after "deploy:update_code", "deploy:pre_announce", "deploy:symlink_configs", "newrelic:notice_deployment"

after "deploy:symlink", "thinking_sphinx:symlink", "deploy:post_announce", "deploy:save_current_branch", "deploy:build_release_html"
before 'deploy:symlink_configs', 'deploy:symlink_cyqueue'
after "deploy:symlink_configs", "hoodiny_custom"

# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"

def campfire_notification( message )
  begin
    unless @room
      @campfire = Tinder::Campfire.new 'hoodiny1', :ssl => true, :token => '3aa7fc18eaa511bfeb21fdae602e3ec175ecab2c'
      @room = @campfire.find_room_by_name 'Team'
    end
    @room.speak message
  rescue => e
    puts "Error trying to paste to Campfire -> #{e.message} (#{e.class})"
  end
end


Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
