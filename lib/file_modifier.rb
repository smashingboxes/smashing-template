require_relative './file_creator.rb'

def api_only_modifications
  api_remove_files
  gsub_file "app/controllers/application_controller.rb", /Base/, "API"
  gsub_file "app/controllers/application_controller.rb", /protect/, "# protect"
end

def generate_readme
  remove_file 'README.rdoc'
  file 'README.md', render_file(path("README.md"))
  gsub_file 'README.md', /app_name/, app_name.upcase
end

def git_ignore_append
  append_file '.gitignore' do
    <<-EOF

# Ignore all secrets and database config files
config/initializers/secret_token.rb
config/secrets.yml
config/database.yml

# Ignore .DS_Store files
.DS_Store
*/.DS_Store
    EOF
  end
end

def api_remove_files
  remove_dir "app/helpers"
  remove_dir "app/views"
  remove_dir "app/assets/javascripts"
  remove_dir "app/assets/stylesheets"
end

def remove_turbolinks
  gsub_file 'app/assets/javascripts/application.js', /= require turbolinks/, ''
  gsub_file 'app/views/layouts/application.html.erb', /, 'data-turbolinks-track' => true/, ""
end

def remove_test_dir
  remove_dir "test"
end

def rubocop_clean_up
  remove_file 'config/initializers/backtrace_silencers.rb'
  gsub_file 'config/environments/production.rb', /^\s*#.*\n/, ''
  gsub_file 'db/seeds.rb', /^\s*#.*\n/, ''
  gsub_file 'spec/spec_helper.rb', / != 0/, ".exitstatus.nonzero?"
  if @cucumber_capybara
    remove_file 'lib/tasks/cucumber.rake'
    file 'lib/tasks/cucumber.rake', render_file(path("cucumber.rake"))
    remove_file 'features/support/env.rb'
    file 'features/support/env.rb', render_file(path("env.rb"))
    remove_file 'script/cucumber'
    file 'script/cucumber', render_file(path("cucumber"))
  end
  if @devise
    gsub_file 'config/initializers/devise.rb', /^\s*#.*\n/, ''
  end
end
