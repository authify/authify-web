# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

namespace :docker do
  desc 'Build a fresh docker image'
  task :build do
    exec 'docker build -t authify/web .'
  end
end
