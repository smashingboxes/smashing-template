# Run using
# rails new APP_NAME -m smashing-template.rb

remove_file "Gemfile"
create_file "Gemfile", <<-EOF
source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# Use Unicorn as the app server
gem 'unicorn'
# Use Taperole for deployment
gem 'taperole'

group :development, :test do
  # Use rspec as the testing framework
  gem 'rspec-rails'
  # Use factory girl for fixtures
  gem 'factory_girl_rails'
  # Use database cleaner for cleaning the database
  gem 'database_cleaner'
  # Call 'binding.pry' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'
  # Use awesome-print to pretty print Ruby objects
  gem 'awesome_print'
  # Use rubocop for linting
  gem 'rubocop'
  # Use shouldamatchers to test associations and validations
  gem 'shoulda-matchers'
  # Use to integrate Code Climate and Travis
  gem "codeclimate-test-reporter", require: nil
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
EOF

# Remove all turbolinks code
gsub_file 'app/assets/javascripts/application.js', /\/\/= require turbolinks/, ''
gsub_file 'app/views/layouts/application.html.erb', /, 'data-turbolinks-track' => true/, ""

# Remove test folder
remove_dir "test"

# Generate ReadMe.md
remove_file 'README.rdoc'
create_file "README.md", <<-EOF
#{app_name}
EOF

# Generate rspec files: .rspec, spec/spec_helper.rb, spec-rails_helper.rb
generate 'rspec:install'

# Generate tape files
run 'tape installer install'

inside 'spec' do
  # Add config for factorygirl
  insert_into_file 'rails_helper.rb',
    '
  config.include FactoryGirl::Syntax::Methods',
                   after: "RSpec.configure do |config|\n"

  # Add config for databasecleaner
  insert_into_file 'rails_helper.rb',
    '  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end',
   after: "RSpec.configure do |config|\n"

  # Add config for shouldamatchers
  insert_into_file 'rails_helper.rb',
'Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end',
  after: "# Add additional requires below this line. Rails is not loaded until this point!\n"

  inject_into_file 'spec_helper.rb', after: "# users commonly want.\n" do <<-RUBY
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
  RUBY
  end
end

# Postgresql database
remove_file "config/database.yml"
create_file "config/database.yml", <<-EOF
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5

development:
  <<: *default
  database: #{app_name}_development

test:
  <<: *default
  database: #{app_name}_test

production:
  <<: *default
  database: #{app_name}_production
  username: #{app_name}
  password: <%= ENV['#{app_name}_DATABASE_PASSWORD'] %>
EOF

# SmashingDocs
if yes?("Add SmashingDocs for API documentation?")
  inject_into_file 'Gemfile', after: "group :development, :test do\n" do <<-RUBY
  # Use smashing_docs for API documentation
  gem 'smashing_docs'
  RUBY
  end
  run 'bundle'
  generate 'docs:install'
end

# Devise
if yes?("Add Devise?")
  inject_into_file 'Gemfile', after: "gem 'taperole'\n" do <<-RUBY
gem 'devise'
  RUBY
  end
  run 'bundle'
  generate 'devise:install'
end

# ActiveAdmin
if yes?("Add ActiveAdmin?")
  gsub_file 'Gemfile', /^gem\s+["']devise["'].*$/,''
  inject_into_file 'Gemfile', after: "gem 'taperole'\n" do <<-RUBY
# Use activeadmin for admin interface
gem 'activeadmin'
gem 'devise'
  RUBY
  end
  run 'bundle'
  generate 'active_admin:install'
end

# Cucumber and Capybara
if yes?("Add Cucumber and Capybara?")
  inject_into_file 'Gemfile', after: "group :development, :test do\n" do <<-RUBY
  # Use cucumber-rails for automated feature tests
  gem 'cucumber-rails', :require => false
  # Use capybara-rails to simulate how a user interacts with the app
  gem 'capybara'
  RUBY
  end
  run 'bundle'
  generate 'cucumber:install'
end

run 'bundle install'

# Add files for travis and linting
run "cp config/database.yml config/database.example.yml"
run "cp config/secrets.yml config/secrets.example.yml"

# Create travis.yml file
create_file '.travis.yml', <<-EOF
  language: ruby
  rvm:
  - 2.3.0
  before_script:
  - cp config/database.example.yml config/database.yml
  - cp config/secrets.example.yml config/secrets.yml
  - psql -c 'create database #{app_name}_test;' -U postgres
  - bundle exec rake db:migrate --trace
  - bundle exec rake db:test:prepare --trace
  script:
  - bundle exec rubocop
  - bundle exec rspec
EOF

# Ignore all secrets and database config files
append_file '.gitignore' do <<-EOF

# Ignore all secrets and database config files
config/initializers/secret_token.rb
config/secrets.yml
config/database.yml
EOF
end

# Create rubocop linting file
create_file '.rubocop.yml', <<-EOF
'AllCops:
Exclude:
  - "vendor/**/*"
  - "db/schema.rb"
  - "bin/*"
UseCache: false
Style/CollectionMethods:
Description: Preferred collection methods.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#map-find-select-reduce-size
Enabled: false
PreferredMethods:
  collect: map
  collect!: map!
  find_all: select
  reduce: inject
Style/DotPosition:
Description: Checks the position of the dot in multi-line method calls.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#consistent-multi-line-chains
Enabled: true
EnforcedStyle: leading
SupportedStyles:
- leading
- trailing
Style/Lambda:
Enabled: false
Style/FileName:
Description: Use snake_case for source file names.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#snake-case-files
Enabled: false
Exclude: []
Style/GuardClause:
Description: Check for conditionals that can be replaced with guard clauses
StyleGuide: https://github.com/bbatsov/ruby-style-guide#no-nested-conditionals
Enabled: false
MinBodyLength: 1
Style/IfUnlessModifier:
Description: Favor modifier if/unless usage when you have a single-line body.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#if-as-a-modifier
Enabled: false
MaxLineLength: 100
Style/OptionHash:
Description: Don't use option hashes when you can use keyword arguments.
Enabled: false
Style/PercentLiteralDelimiters:
Description: Use `%`-literal delimiters consistently
StyleGuide: https://github.com/bbatsov/ruby-style-guide#percent-literal-braces
Enabled: false
PreferredDelimiters:
  "%": "()"
  "%i": "()"
  "%q": "()"
  "%Q": "()"
  "%r": "{}"
  "%s": "()"
  "%w": "()"
  "%W": "()"
  "%x": "()"
Style/PredicateName:
Description: Check the names of predicate methods.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#bool-methods-qmark
Enabled: false
NamePrefix:
- is_
- has_
- have_
NamePrefixBlacklist:
- is_
Exclude:
- spec/**/*
Style/RaiseArgs:
Description: Checks the arguments passed to raise/fail.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#exception-class-messages
Enabled: false
EnforcedStyle: exploded
SupportedStyles:
- compact
- exploded
Style/SignalException:
Description: Checks for proper usage of fail and raise.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#fail-method
Enabled: false
EnforcedStyle: semantic
SupportedStyles:
- only_raise
- only_fail
- semantic
Style/SingleLineBlockParams:
Description: Enforces the names of some block params.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#reduce-blocks
Enabled: false
Methods:
- reduce:
  - a
  - e
- inject:
  - a
  - e
Style/SingleLineMethods:
Description: Avoid single-line methods.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#no-single-line-methods
Enabled: false
AllowIfMethodIsEmpty: true
Style/StringLiterals:
Enabled: false
Style/StringLiteralsInInterpolation:
Description: Checks if uses of quotes inside expressions in interpolated strings
  match the configured preference.
Enabled: false
EnforcedStyle: single_quotes
SupportedStyles:
- single_quotes
- double_quotes
Style/TrailingCommaInArguments:
Description: Checks for trailing comma in argument lists.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#no-trailing-array-commas
Enabled: false
EnforcedStyleForMultiline: no_comma
SupportedStyles:
- comma
- consistent_comma
- no_comma
Style/TrailingCommaInLiteral:
Description: Checks for trailing comma in array and hash literals.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#no-trailing-array-commas
Enabled: false
EnforcedStyleForMultiline: no_comma
SupportedStyles:
- comma
- consistent_comma
- no_comma
Metrics/AbcSize:
Description: A calculated magnitude based on number of assignments, branches, and
  conditions.
Enabled: false
Max: 15
Metrics/ClassLength:
Description: Avoid classes longer than 100 lines of code.
Enabled: false
CountComments: false
Max: 100
Metrics/ModuleLength:
CountComments: false
Max: 100
Description: Avoid modules longer than 100 lines of code.
Enabled: false
Metrics/CyclomaticComplexity:
Description: A complexity metric that is strongly correlated to the number of test
  cases needed to validate a method.
Enabled: false
Max: 6
Metrics/MethodLength:
Description: Avoid methods longer than 10 lines of code.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#short-methods
Enabled: false
CountComments: false
Max: 10
Metrics/ParameterLists:
Description: Avoid parameter lists longer than three or four parameters.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#too-many-params
Enabled: false
Max: 5
CountKeywordArgs: true
Metrics/PerceivedComplexity:
Description: A complexity metric geared towards measuring complexity for a human
  reader.
Enabled: false
Max: 7
Metrics/LineLength:
Max: 100
# To make it possible to copy or click on URIs in the code, we allow lines
# contaning a URI to be longer than Max.
AllowURI: true
URISchemes:
  - http
  - https
Lint/AssignmentInCondition:
Description: Don't use assignment in conditions.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#safe-assignment-in-condition
Enabled: false
AllowSafeAssignment: true
Style/BlockComments:
Enabled: false
Style/ClassAndModuleChildren:
Enabled: false
Style/InlineComment:
Description: Avoid inline comments.
Enabled: false
Style/AccessorMethodName:
Description: Check the naming of accessor methods for get_/set_.
Enabled: fals
Style/Alias:
Description: Use alias_method instead of alias.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#alias-method
Enabled: false
Style/Documentation:
Description: Document classes and non-namespace modules.
Enabled: false
Style/DoubleNegation:
Description: Checks for uses of double negation (!!).
StyleGuide: https://github.com/bbatsov/ruby-style-guide#no-bang-bang
Enabled: false
Style/EachWithObject:
Description: Prefer `each_with_object` over `inject` or `reduce`.
Enabled: false
Style/EmptyLiteral:
Description: Prefer literals to Array.new/Hash.new/String.new.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#literal-array-hash
Enabled: false
Style/ModuleFunction:
Description: Checks for usage of `extend self` in modules.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#module-function
Enabled: false
Style/OneLineConditional:
Description: Favor the ternary operator(?:) over if/then/else/end constructs.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#ternary-operator
Enabled: false
Style/PerlBackrefs:
Description: Avoid Perl-style regex back references.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#no-perl-regexp-last-matchers
Enabled: false
Style/Send:
Description: Prefer `Object#__send__` or `Object#public_send` to `send`, as `send`
  may overlap with existing methods.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#prefer-public-send
Enabled: false
Style/SpecialGlobalVars:
Description: Avoid Perl-style global variables.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#no-cryptic-perlisms
Enabled: false
Style/VariableInterpolation:
Description: Don't interpolate global, instance and class variables directly in
  strings.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#curlies-interpolate
Enabled: false
Style/WhenThen:
Description: Use when x then ... for one-line cases.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#one-line-cases
Enabled: false
Lint/EachWithObjectArgument:
Description: Check for immutable argument given to each_with_object.
Enabled: true
Lint/HandleExceptions:
Description: Don't suppress exception.
StyleGuide: https://github.com/bbatsov/ruby-style-guide#dont-hide-exceptions
Enabled: false
Lint/LiteralInCondition:
Description: Checks of literals used in conditions.
Enabled: false
Lint/LiteralInInterpolation:
Description: Checks for literals used in interpolation.
Enabled: false
Rails/Output:
Enabled: false'
EOF

# Set up git repository
git :init
