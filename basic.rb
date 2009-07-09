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
run "cp config/database.yml config/example_database.yml"

run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.3.2.js > public/javascripts/jquery-1.3.2.js"

git :init
git :add => ".", :commit => "-m 'Initial commit'"

plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git'
rake "asset:packager:create_yml"
git :add => ".", :commit => "-m 'Add asset_packager plugin'"

plugin 'html_output', :git => 'git://github.com/jonleighton/html_output.git'
git :add => ".", :commit => "-m 'Add html output plugin'"

if yes?('Authorization with Authlogic?')
  plugin 'authlogic', :git => 'git://github.com/binarylogic/authlogic.git'
  git :add => ".", :commit => "-m 'Add authlogic plugin'"
end

if yes?('Use attachments?')
  if yes?('Images only? (Paperclip)')
    plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git'
    git :add => ".", :commit => "-m 'Add paperclip plugin'"
  else
    plugin 'attachment_fu', :git => 'git://github.com/technoweenie/attachment_fu.git'  
    git :add => ".", :commit => "-m 'Add attachment_fu plugin'"
  end
end
