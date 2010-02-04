file ".gitignore", <<-END  
.DS_Store
config/database.yml
db/*.sqlite3
doc/api
doc/app
log/*.log
public/javascripts/*_packaged.js
public/javascripts/all.js
public/stylesheets/*_packaged.css
public/stylesheets/all.css
tmp/**/*
END

run "rm README public/index.html public/favicon.ico public/robots.txt"
run "rm -f public/javascripts/*"

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"  

run "curl --progress-bar -L http://jqueryjs.googlecode.com/files/jquery-1.4.1.js > public/javascripts/jquery-1.4.1.js"

git :init
git :add => "."
git :commit => "-m 'Initial commit'"

plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git'
rake "asset:packager:create_yml"
git :add => "."
git :commit => "-m 'Add asset_packager plugin'"

plugin "pretty_flash", :git => 'git://github.com/rpheath/pretty_flash.git'
git :add => '.'
git :commit => "-m 'Add pretty flash plgin'"

if yes?('Authorization?')
  if yes?('with Authlogic?')
    plugin 'authlogic', :git => 'git://github.com/binarylogic/authlogic.git'
    git :add => "."
    git :commit => "-m 'Add authlogic plugin'"
  elsif yes?('with devise?')
    gem 'warden'
    gem 'devise'
    run "rake gems:install"
    generate :devise_install
    git :add => "."
    git :commit => "-m 'Add devise authorization'"    
  end
end

if yes?('Planning on translating the application?')
  plugin 'translate_routes', :git => 'git://github.com/raul/translate_routes.git'
  git :add => '.'
  git :commit => "-m 'Add i18n helper plugin'"
end

if yes?('Are you going to need background processes/daemons?')
  plugin 'delayed_job', :git => 'git://github.com/collectiveidea/delayed_job.git'
  generate :delayed_job
  git :add => '.'
  git :commit => "-m 'Add delayed_job plugin'"
end

if yes?('Going to working with date and time and need such validations?')
  plugin 'validates_timeliness', :git => 'git://github.com/adzap/validates_timeliness.git'
  git :add => '.'
  git :commit => "-m 'Add validates_timeliness plugin'"
end

if yes?('Need pagination?')
  plugin 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git'
  git :add => '.'
  git :commit => "-m 'Add will_paginate plugin'"
end

if yes?('Going to use attachments?')
  if yes?('Images only? (Paperclip, images as attributes)')
    plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git'
    git :add => "."
    git :commit => "-m 'Add paperclip plugin'"
  else
    plugin 'attachment_fu', :git => 'git://github.com/technoweenie/attachment_fu.git'  
    git :add => "."
    git :commit => "-m 'Add attachment_fu plugin'"
  end
end

if yes?('Haml?')
  gem 'haml'
  run "rake gems:install"
  run "haml --rails ."
  git :add => '.'
  git :commit => "-m 'Add haml plugin'"
else
  plugin 'html_output', :git => 'git://github.com/jonleighton/html_output.git'
  git :add => "."
  git :commit => "-m 'Add html output plugin'"
end

if yes?('LESS css?')
  gem 'less'
  run "rake gems:install"
  plugin 'more', :git => 'git://github.com/cloudhead/more.git'
  git :add => '.'
  git :commit => "-m 'Add less for rails (more) plugin'"
end

if yes?('Capistrano integration?')
  run "capify ."
  db_script = '
  # 
  # = Capistrano database.yml task
  #
  # Provides a couple of tasks for creating the database.yml 
  # configuration file dynamically when deploy:setup is run.
  #
  # Category::    Capistrano
  # Package::     Database
  # Author::      Simone Carletti <weppos@weppos.net>
  # Copyright::   2007-2009 The Authors
  # License::     MIT License
  # Link::        http://www.simonecarletti.com/
  # Source::      http://gist.github.com/2769
  #
  #
  # == Requirements
  #
  # This extension requires the original <tt>config/database.yml</tt> to be excluded
  # from source code checkout. You can easily accomplish this by renaming
  # the file (for example to database.example.yml) and appending <tt>database.yml</tt>
  # value to your SCM ignore list.
  #
  #   # Example for Subversion
  #
  #   $ svn mv config/database.yml config/database.example.yml
  #   $ svn propset svn:ignore \'database.yml\' config
  #
  #   # Example for Git
  #
  #   $ git mv config/database.yml config/database.example.yml
  #   $ echo \'config/database.yml\' >> .gitignore 
  #
  # 
  # == Usage
  # 
  # Include this file in your <tt>deploy.rb</tt> configuration file.
  # Assuming you saved this recipe as capistrano_database_yml.rb:
  # 
  #   require "capistrano_database_yml"
  # 
  # Now, when <tt>deploy:setup</tt> is called, this script will automatically
  # create the <tt>database.yml</tt> file in the shared folder.
  # Each time you run a deploy, this script will also create a symlink
  # from your application <tt>config/database.yml</tt> pointing to the shared configuration file. 
  # 
  # == Custom template
  # 
  # By default, this script creates an exact copy of the default
  # <tt>database.yml</tt> file shipped with a new Rails 2.x application.
  # If you want to overwrite the default template, simply create a custom Erb template
  # called <tt>database.yml.erb</tt> and save it into <tt>config/deploy</tt> folder.
  # 
  # Although the name of the file can\'t be changed, you can customize the directory
  # where it is stored defining a variable called <tt>:template_dir</tt>.
  # 
  #   # store your custom template at foo/bar/database.yml.erb
  #   set :template_dir, "foo/bar"
  # 
  #   # example of database template
  #   
  #   base: &base
  #     adapter: sqlite3
  #     timeout: 5000
  #   development:
  #     database: #{shared_path}/db/development.sqlite3
  #     <<: *base
  #   test:
  #     database: #{shared_path}/db/test.sqlite3
  #     <<: *base
  #   production:
  #     adapter: mysql
  #     database: #{application}_production
  #     username: #{user}
  #     password: #{Capistrano::CLI.ui.ask("Enter MySQL database password: ")}
  #     encoding: utf8
  #     timeout: 5000
  #
  # Because this is an Erb template, you can place variables and Ruby scripts
  # within the file.
  # For instance, the template above takes advantage of Capistrano CLI
  # to ask for a MySQL database password instead of hard coding it into the template.
  #
  # === Password prompt
  #
  # For security reasons, in the example below the password is not
  # hard coded (or stored in a variable) but asked on setup.
  # I don\'t like to store passwords in files under version control
  # because they will live forever in your history.
  # This is why I use the Capistrano::CLI utility.
  #

  unless Capistrano::Configuration.respond_to?(:instance)
    abort "This extension requires Capistrano 2"
  end

  Capistrano::Configuration.instance.load do

    namespace :db do

      desc <<-DESC
        Creates the database.yml configuration file in shared path.

        By default, this task uses a template unless a template \
        called database.yml.erb is found either is :template_dir \
        or /config/deploy folders. The default template matches \
        the template for config/database.yml file shipped with Rails.

        When this recipe is loaded, db:setup is automatically configured \
        to be invoked after deploy:setup. You can skip this task setting \
        the variable :skip_db_setup to true. This is especially useful \ 
        if you are using this recipe in combination with \
        capistrano-ext/multistaging to avoid multiple db:setup calls \ 
        when running deploy:setup for all stages one by one.
      DESC
      task :setup, :except => { :no_release => true } do

        default_template = <<-EOF
        base: &base
          adapter: sqlite3
          timeout: 5000
        development:
          database: #{shared_path}/db/development.sqlite3
          <<: *base
        test:
          database: #{shared_path}/db/test.sqlite3
          <<: *base
        production:
          database: #{shared_path}/db/production.sqlite3
          <<: *base
        EOF

        location = fetch(:template_dir, "config/deploy") + \'/database.yml.erb\'
        template = File.file?(location) ? File.read(location) : default_template

        config = ERB.new(template)

        run "mkdir -p #{shared_path}/db" 
        run "mkdir -p #{shared_path}/config" 
        put config.result(binding), "#{shared_path}/config/database.yml"
      end

      desc <<-DESC
        [internal] Updates the symlink for database.yml file to the just deployed release.
      DESC
      task :symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
      end

    end

    after "deploy:setup",           "db:setup"   unless fetch(:skip_db_setup, false)
    after "deploy:finalize_update", "db:symlink"

  end
  
  '
  
  db_template = '
  # store your custom template at foo/bar/database.yml.erb
  set :template_dir, "foo/bar"
  #
  # example of database template

  base: &base
    adapter: sqlite3
    timeout: 5000
  development:
    database: #{shared_path}/db/development.sqlite3
    <<: *base
  test:
    database: #{shared_path}/db/test.sqlite3
    <<: *base
  production:
    adapter: #{Capistrano::CLI.ui.ask("Enter db adapter: [mysql] ") {|q| q.default = "mysql"}}
    database: #{Capistrano::CLI.ui.ask("Enter db name: [#{application}_production] ") {|q| q.default = "#{application}_production"}}
    username: #{Capistrano::CLI.ui.ask("Enter db user: ")}
    password: #{Capistrano::CLI.ui.ask("Enter db password: ")}
    encoding: utf8
    timeout: 5000
    
  '
  
  folder = "config/deploy"
  Dir.mkdir(folder) unless File.exists?(folder)
  File.open("#{folder}/database.rb", 'w') {|f| f.write(db_script)}
  File.open("#{folder}/database.yml.erb", 'w') {|f| f.write(db_template)}
  File.open("#{folder}.rb", 'a') do |f|
    f.write("\nrequire File.expand_path(File.dirname(__FILE__) + '/deploy/database.rb')'")
  end
  
  git :add => '.'
  git :commit => "-m 'Capistrano integration'"
else
  run "cp config/database.yml config/example_database.yml"
  git :add => '.'
  git :commit => "-m 'Db file copied to config/database.yml'"
end
