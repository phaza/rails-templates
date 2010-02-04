if yes?('using compass css authoring tool?')
  gem 'compass', :version => '>= 0.10.0.pre2'
  gem 'compass-baseline', :lib => 'baseline'
  gem 'fancy-buttons'
  rake 'gems:install'
  run 'compass --rails -r compass-colors -r fancy-buttons -f fancy-buttons . --css-dir=public/stylesheets/compiled --sass-dir=app/stylesheets'
  
  File.open("#{RAILS_ROOT}/config/compass.rb", 'r+') do |f|
    lines = f.readlines
    lines.unshift("require 'baseline'\n")
    lines << <<-ZAP
      sass_options = {:cache_location => "#{Compass.configuration.project_path}/tmp/sass-cache"}
    ZAP
    f.pos = 0
    f.write(lines)
  end
  
end