def database_set_up
  remove_file "config/database.yml"
  file 'config/database.yml', render_file("#{$path}/files/database.yml")
  gsub_file 'config/database.yml', /app_name/, app_name
end

def travis_set_up
  run "cp config/database.yml config/database.example.yml"
  run "cp config/secrets.yml config/secrets.example.yml"
  file '.travis.yml', render_file("#{$path}/files/.travis.yml")
  gsub_file '.travis.yml', /app_name/, app_name
  file '.rubocop.yml', render_file("#{$path}/files/.rubocop.yml")
end

def create_database
  run 'rake db:create'
end
