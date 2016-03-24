def add_gem_configs
  bundle
  rspec_config
  read_configs
  factory_girl_config
  database_cleaner_config
  shoulda_matchers_config
  code_climate_config
  tape_config
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

def tape_config
  run 'tape installer install'
end

def smashing_docs?
  if yes?("Add smashing_docs for API documentation? (y/n)")
    @smashing_docs = true
    inject_into_file 'Gemfile', after: "group :development, :test do\n" do <<-RUBY
  # Use smashing_docs for API documentation
  gem 'smashing_docs'
    RUBY
    end
  end
end

def devise_auth?
  if yes?("Add devise_token_auth? (y/n)")
    @devise_auth = true
    inject_into_file 'Gemfile', after: "gem 'taperole'\n" do <<-RUBY
gem 'devise_token_auth'
    RUBY
    end
  end
end

def devise?
  if yes?("Add devise? (y/n)")
    @devise = true
    inject_into_file 'Gemfile', after: "gem 'taperole'\n" do <<-RUBY
gem 'devise'
    RUBY
    end
  end
end

def cucumber_capybara?
  if yes?("Add cucumber-rails and capybara? (y/n)")
    @cucumber_capybara = true
    inject_into_file 'Gemfile', after: "group :development, :test do\n" do <<-RUBY
  # Use cucumber-rails for automated feature tests
  gem 'cucumber-rails', require: false
  # Use capybara-rails to simulate how a user interacts with the app
  gem 'capybara'
    RUBY
    end
  end
end

def install_optional_gems
  bundle if @smashing_docs || @devise || @devise_auth || @active_admin || @cucumber_capybara
  generate 'docs:install' if @smashing_docs
  generate 'devise:install' if @devise
  generate 'active_admin:install' if @active_admin
  generate 'cucumber:install' if @cucumber_capybara
end
