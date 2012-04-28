set :stages, %w(production)
set :default_stage, 'production'
require 'capistrano/ext/multistage'

set :application, "bull"
set :domain,      "bull.9elements.com"
set :user,        "bull"
set :repository,  "git://github.com/dhoelzgen/bull.git"

set :use_sudo,    false

ssh_options[:forward_agent] = true
set :scm, :git
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do

  task :start, :roles => :app do
    run "cd #{current_path}; npm install; NODE_ENV=#{node_env} forever start -c coffee server.coffee"
  end

  task :stop, :roles => :app do
    run "cd #{current_path}; forever stopall;"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path}; npm install; forever stopall; NODE_ENV=#{node_env} forever start -c coffee server.coffee"
  end

end
