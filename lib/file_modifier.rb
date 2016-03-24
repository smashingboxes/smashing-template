require_relative './file_creator.rb'

def api_only_modifications
  api_remove_files
  gsub_file "app/controllers/application_controller.rb", /Base/, "API"
  gsub_file "app/controllers/application_controller.rb", /protect/, "# protect"
end

def generate_readme
  remove_file 'README.rdoc'
  file 'README.md', render_file("#{$path}/files/README.md")
  gsub_file 'README.md', /app_name/, app_name.upcase
end

def git_ignore_append
  append_file '.gitignore' do <<-EOF

  # Ignore all secrets and database config files
  config/initializers/secret_token.rb
  config/secrets.yml
  config/database.yml
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
  gsub_file 'app/assets/javascripts/application.js', /\/\/= require turbolinks/, ''
  gsub_file 'app/views/layouts/application.html.erb', /, 'data-turbolinks-track' => true/, ""
end

def remove_test_dir
  remove_dir "test"
end
