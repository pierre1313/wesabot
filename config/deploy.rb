set :application, "wesabot"
set :repository,  "git@github.com:hackarts/wesabot.git"

set :scm, :git
set :branch, "master"
set :deploy_to, "/home/wes/#{application}"
set :user, "wes"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

role :app, "wesplease.com"
role :web, "wesplease.com"
role :db,  "wesplease.com", :primary => true

set :use_sudo, false