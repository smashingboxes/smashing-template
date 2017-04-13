require_relative './file_creator.rb'

def add_gem_configs
  update_rubygems unless rails_4_app?
  bundle
  rspec_config
  read_configs
  factory_girl_config
  database_cleaner_config
  shoulda_matchers_config
  code_climate_config
  rubocop_config
  tape_config
  update_ruby_advisory_db
end

def update_rubygems
  run 'gem update --system'
end

def bundle
  run 'bundle'
end

def rspec_config
  generate 'rspec:install'
end

def read_configs
  gsub_file 'spec/rails_helper.rb', /# Dir/, "Dir"
end

def factory_girl_config
  file 'spec/support/factory_girl.rb', render_file(path("factory_girl.rb"))
end

def database_cleaner_config
  file 'spec/support/database_cleaner.rb', render_file(path("database_cleaner.rb"))
end

def shoulda_matchers_config
  file 'spec/support/shoulda_matchers.rb', render_file(path("shoulda_matchers.rb"))
end

def code_climate_config
  inside 'spec' do
    inject_into_file 'spec_helper.rb', after: "# users commonly want.\n" do
      <<-RUBY
if ENV['GENERATE_COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start 'rails'
end
      RUBY
    end
  end
end

def rubocop_config
  inside 'spec' do
    inject_into_file 'spec_helper.rb', after: "RSpec.configure do |config|\n" do
      <<-'RUBY'
  config.after(:suite) do
    examples = RSpec.world.filtered_examples.values.flatten
    after_hooks = ["bundle exec rubocop",
                   "brakeman -q -w2 -z --no-summary",
                   "bundle-audit --update"]
    if examples.none?(&:exception)
      after_hooks.each do |hook_command|
        system("echo ' ' && #{hook_command}")
        exitstatus = $?.exitstatus
        exit exitstatus if exitstatus.nonzero?
      end
    end
  end
      RUBY
    end
  end
end

def tape_config
  run 'tape installer install'
end

def update_ruby_advisory_db
  run 'bundle-audit --update'
end

def smashing_docs?
  if yes?("Add smashing_docs for API documentation? (y/n)")
    @smashing_docs = true
    inject_into_file 'Gemfile', after: "group :development, :test do\n" do
      <<-RUBY
  # Use smashing_docs for API documentation
  gem 'smashing_docs'
      RUBY
    end
  end
end

def devise_auth?
  if yes?("Add devise_token_auth? (y/n)")
    @devise_auth = true
    inject_into_file 'Gemfile', after: "gem 'taperole'\n" do
      <<-RUBY
gem 'devise_token_auth'
      RUBY
    end
  end
end

def devise?
  if yes?("Add devise? (y/n)")
    @devise = true
    inject_into_file 'Gemfile', after: "gem 'taperole'\n" do
      <<-RUBY
gem 'devise'
      RUBY
    end
  end
end

def cucumber_capybara?
  if yes?("Add cucumber-rails and capybara? (y/n)")
    @cucumber_capybara = true
    inject_into_file 'Gemfile', after: "group :development, :test do\n" do
      <<-RUBY
  # Use cucumber-rails for automated feature tests
  gem 'cucumber-rails', require: false
  # Use capybara to simulate how a user interacts with the app
  gem 'capybara'
      RUBY
    end
  end
end

def active_admin?
  if yes?("Would you like to use admin interface ActiveAdmin? (y/n)")
    @active_admin = true
    inject_into_file 'Gemfile', after: "gem 'taperole'\n" do
      <<-RUBY
# Use active_admin for admin interface
gem 'activeadmin', '~> 1.0.0.pre4'
# To use preliminary support of ActiveAdmin with Rails 5
gem 'inherited_resources', github: 'activeadmin/inherited_resources'
      RUBY
    end
  end
  unless @devise
    inject_into_file 'Gemfile', after: "gem 'taperole'\n" do
      <<-RUBY
# To add authentication to ActiveAdmin interface
gem 'devise'
      RUBY
    end
  end
end

def active_admin_rubocop_clean_up
  gsub_file 'app/admin/admin_user.rb', /\nend/, "end"
  gsub_file 'app/admin/dashboard.rb', /do\n\n/, "do\n"
  gsub_file 'app/admin/dashboard.rb', /\{/, " {"
  gsub_file 'app/models/admin_user.rb', /,\s\n\s+/, ", "
  gsub_file 'config/initializers/active_admin.rb', /an options/, "options"
  gsub_file 'config/initializers/active_admin.rb', /My Great Website/, "Website"
  gsub_file 'config/initializers/active_admin.rb', /mygreatwebsite/, "website"
  gsub_file 'spec/factories/admin_users.rb', /\n/, ""
end

def install_optional_gems
  bundle if @smashing_docs || @devise || @devise_auth || @cucumber_capybara
  generate 'docs:install' if @smashing_docs
  generate 'devise:install' if @devise
  generate 'cucumber:install' if @cucumber_capybara
  if @active_admin
    generate 'active_admin:install'
    active_admin_rubocop_clean_up
  end
end
