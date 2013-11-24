set :repository,  "https://github.com/rubayte/edivaApp.git"  ## giturl
set :user, "rrahman" ## username of passenger
set :use_sudo, false ## no sudo 
set :scm, :git ## version control : git
set :deploy_to, "/var/www/html/ediva"  ## place to deploy in server


role :web, "www.ediva.crg.eu"                          # Your HTTP server, Apache/etc
role :app, "www.ediva.crg.eu"                          # This may be the same as your `Web` server
role :db,  "www.ediva.crg.eu", :primary => true        # This is where Rails migrations will run

#after "deploy", "deploy:bundle_gems"
#after "deploy:bundle_gems", "deploy:restart"


namespace :deploy do
   task :bundle_gems do
     run "cd #{deploy_to}/current"
   end
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end