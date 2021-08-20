# config valid only for current version of Capistrano
lock '3.16.0'

set :application, 'spinner'
set :repo_url, 'https://github.com/aschmitz/spinner'

# Default branch is :master
set :branch, ENV.fetch('GIT_BRANCH', 'master')

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/spinner'

set :puma_bind, 'tcp://127.0.0.1:8080'
set :puma_threads, [0,5]

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/cable.yml',
  'config/database.yml',
  'config/secrets.yml',
  'config/storage.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp', 'public/system', 'node_modules'

# Default value for default_env is {}
# set :default_env, { path: '/opt/ruby/bin:$PATH' }

# Default value for keep_releases is 5
# set :keep_releases, 5

after 'deploy:publishing', 'systemd:spinner_mopidy:restart'
