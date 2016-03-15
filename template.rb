$path = File.expand_path(File.dirname(__FILE__))

def render_file(path)
  file = IO.read(path)
end

def api_only_install
  @api_only = true
  remove_dir "app/helpers"
  remove_dir "app/views"
  remove_dir "app/assets/javascripts"
  remove_dir "app/assets/stylesheets"
  gsub_file "app/controllers/application_controller.rb", /Base/, "API"
  gsub_file "app/controllers/application_controller.rb", /protect/, "# protect"
  api_only_gemfile
end

def api_only_gemfile
  file "Gemfile", render_file("#{$path}/files/Gemfile_api_only")
end

def integrated_app_install
  integrated_app_gemfile
  remove_turbolinks
end

def integrated_app_gemfile
  file "Gemfile", render_file("#{$path}/files/Gemfile")
end

def remove_turbolinks
  gsub_file 'app/assets/javascripts/application.js', /\/\/= require turbolinks/, ''
  gsub_file 'app/views/layouts/application.html.erb', /, 'data-turbolinks-track' => true/, ""
end

def add_gem_configs
  bundle
  rspec_config
  factory_girl_config
  database_cleaner_config
  shoulda_matchers_config
  code_climate_config
end

def bundle
  run 'bundle'
end

def rspec_config
  generate 'rspec:install'
end

def factory_girl_config
  file 'spec/support/factory_girl.rb', render_file("#{$path}/files/factory_girl.rb")
end

def database_cleaner_config
  file 'spec/support/database_cleaner.rb', render_file("#{$path}/files/database_cleaner.rb")
end

def shoulda_matchers_config
  file 'spec/support/shoulda_matchers.rb', render_file("#{$path}/files/shoulda_matchers.rb")
end

def code_climate_config
  inside 'spec' do
    inject_into_file 'spec_helper.rb', after: "# users commonly want.\n" do <<-RUBY
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
    RUBY
    end
  end
end

def generate_readme
  remove_file 'README.rdoc'
  file 'README.md', render_file("#{$path}/files/README.md")
  gsub_file 'README.md', /app_name/, app_name.upcase
end

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

def git_ignore_append
  append_file '.gitignore' do <<-EOF

  # Ignore all secrets and database config files
  config/initializers/secret_token.rb
  config/secrets.yml
  config/database.yml
  EOF
  end
end

def smashing_docs?
  if yes?("Add SmashingDocs for API documentation? (y/n)")
    @smashing_docs = true
    inject_into_file 'Gemfile', after: "group :development, :test do\n" do <<-RUBY
    # Use smashing_docs for API documentation
    gem 'smashing_docs'
    RUBY
    end
  end
end

def devise?
  if @api_only
    # Devise
    if yes?("Add Devise_Auth? (y/n)")
      @devise = true
      inject_into_file 'Gemfile', after: "gem 'taperole'\n" do <<-RUBY
    gem 'devise_token_auth'
      RUBY
      end
    end
  else
    if yes?("Add Devise? (y/n)")
      @devise = true
      inject_into_file 'Gemfile', after: "gem 'taperole'\n" do <<-RUBY
    gem 'devise'
      RUBY
      end
    end
  end
end

def active_admin?
  unless @api_only
    # ActiveAdmin
    if yes?("Add ActiveAdmin? (y/n)")
      @active_admin = true
      gsub_file 'Gemfile', /gem 'devise'/, ""
      inject_into_file 'Gemfile', after: "gem 'taperole'\n" do <<-RUBY
  # Use activeadmin for admin interface
  gem 'activeadmin', '~> 1.0.0.pre2'
  gem 'devise'
      RUBY
      end
    end
  end
end

def cucumber_capybara?
  unless @api_only
    # Cucumber and Capybara
    if yes?("Add Cucumber and Capybara? (y/n)")
      @cucumber_capybara = true
      inject_into_file 'Gemfile', after: "group :development, :test do\n" do <<-RUBY
  # Use cucumber-rails for automated feature tests
  gem 'cucumber-rails', :require => false
  # Use capybara-rails to simulate how a user interacts with the app
  gem 'capybara'
      RUBY
      end
    end
  end
end

def install_optional_gems
  bundle if @smashing_docs || @devise || @active_admin || @cucumber_capybara
  generate 'docs:install' if @smashing_docs
  generate 'devise:install' if @devise && @api_only == false
  generate 'active_admin:install' if @active_admin
  generate 'cucumber:install' if @cucumber_capybara
end

# -----------------------------
# CREATE TEMPLATE
# -----------------------------
remove_file "Gemfile"
# -----------------------------
# API ONLY APP?
# -----------------------------
if yes?("Is this an API only app with no front-end or admin interface? (y/n)")
  api_only_install
else
  integrated_app_install
end
# -----------------------------
# SETUP
# -----------------------------
add_gem_configs
remove_dir "test"
generate_readme
# -----------------------------
# DATABASE
# -----------------------------
database_set_up
travis_set_up
git_ignore_append
# -----------------------------
# GEM ADDITIONS (OPTIONAL)
# -----------------------------
smashing_docs?
devise?
active_admin?
cucumber_capybara?

install_optional_gems
# -----------------------------
# DEPLOYMENT
# -----------------------------
run 'tape installer install'
run 'rake db:create'
# -----------------------------
# GIT
# -----------------------------
git :init
# -----------------------------
# COMPLETE
# -----------------------------
puts "\nSmashing-Template successfully created!"
