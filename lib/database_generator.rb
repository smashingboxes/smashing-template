require_relative './file_creator.rb'

def database_set_up
  remove_file "config/database.yml"
  file 'config/database.yml', render_file(path("database.yml"))
  gsub_file 'config/database.yml', /app_name/, app_name
end

def travis_set_up
  run "cp config/database.yml config/database.example.yml"
  run "cp config/secrets.yml config/secrets.example.yml"
  file '.travis.yml', render_file(path(".travis.yml"))
  gsub_file '.travis.yml', /app_name/, app_name
  file '.rubocop.yml', render_file(path(".rubocop.yml"))
  if @cucumber_capybara
    inject_into_file '.travis.yml', after: "- bundle exec rspec\n" do
      <<-RUBY
  - bundle exec rake cucumber
      RUBY
    end
  end
end

def create_database
  run 'rake db:create'
end
