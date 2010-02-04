
# Create a development/test/prod database for a new rails template. 
# Apply to a new Rails application using  rails:template rake task 
# and supplying LOCATION environment variable :                      
#                                                                    
#        rake rails:template LOCATION=/path/to/this_template         

# Snatched from: http://github.com/lgs/rails-templates

require 'etc'

dbname   = ask("\nCreate a new MySQL DB named :")
mysqlusr = ask("\nwith user :")
passwd   = ask("\nand password :")

mysqlusr = Etc.getlogin if mysqlusr.blank?

p mysqlusr.blank?

file 'config/database.yml', <<-YAML
development:
  adapter: mysql
  encoding: utf8
  reconnect: false
  database: #{dbname}
  pool: 5
  username: #{mysqlusr}
  password: #{passwd}
  host: localhost
test:
  adapter: mysql
  encoding: utf8
  reconnect: false
  database: #{dbname}_test
  pool: 5
  username: #{mysqlusr}
  password: #{passwd}
  host: localhost
production:
  adapter: mysql
  encoding: utf8
  reconnect: false
  database: #{dbname}
  pool: 5
  username: #{mysqlusr}
  password: #{passwd}
  host: localhost
YAML

# Run the migration
if yes?("\nCreate and migrate databases now?")
  # run "mysqladmin -u #{mysqlusr} create #{dbname}" -p #{passwd}
  # run "mysqladmin -u #{mysqlusr} create #{dbname}_test" -p #{passwd}
  rake("db:create:all")
  rake("db:migrate")
  git :add => '.'
  git :commit => "-m 'Migrate database'"
end
