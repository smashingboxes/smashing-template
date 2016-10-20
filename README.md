[![Build Status](https://travis-ci.org/smashingboxes/boxcar.svg?branch=master)](https://travis-ci.org/smashingboxes/boxcar)

# Boxcar

Boxcar is the Rails application template used at
[Smashing Boxes](https://smashingboxes.com/) according to our best practices.

## Requirements
This template is compatible with:
  - Rails 5.0.0
  - Rails 4.2.7

The template currently assumes:
  - PostgreSQL

and that the application will be deployed using:
  - Taperole
  - Unicorn

NOTE: Taperole is not yet compatible with Rails 5.

## Installation
To create a new Rails app with this template, do the following:
```
git clone https://github.com/smashingboxes/boxcar.git
```

To use Rails 5, do the following:
```
rails new [app_name] -m boxcar/template.rb -B
```

To use Rails 4, do the following:
```
rails _4.2.7_ new [app_name] -m boxcar/template.rb -B
```

If you run into an issue with Rails 4.2.7, run ```gem install rails -v 4.2.7``` to ensure you have access to this version of Rails.

Note that the ``-B`` is optional and equivalent to ``--skip-bundle``. Since there is a bundle install command inside the template, the final bundle when creating a new Rails app is unnecessary.

Note that this command will be updated when the template is compatible with Rails 5.

## Options
When using this template, you will be asked one or more questions to determine what type of Rails app to generate. There are 3 types of apps you can select:

1. API Only
  - Answer 'y' to the question "Is this an API app? (y/n)".
  - Answer 'n' to the question "Does this API app have an admin interface? (y/n)"
2. API with Admin Interface
  - Answer 'y' to the question "Is this an API app? (y/n)".
  - Answer 'y' to the question "Does this API app have an admin interface? (y/n)"
3. Interactive
  - Answer 'n' to the question "Is this an API app? (y/n)".

## What does it do?
The template will generate a Rails app using ``rails new``, and then will customize the app according to the template. Depending on the type of template you are generating, the template will modify the following:

1. API Only
  - Modify the Gemfile
  - Remove files from the app directory, including helpers, views, and assets > javascripts and stylesheets
  - Modify the application_controller.rb file for an API
  - Option to install the gem 'devise_token_auth'
  - Option to install the gem 'smashing_docs'

2. API with Admin Interface
  - Modify the Gemfile  
  - Remove Turbolinks
  - Option to install the gem 'devise_token_auth'
  - Option to install the gems 'cucumber-rails' and 'capybara'
  - Option to install the gem 'smashing_docs'

3. Interactive
  - Modify the Gemfile
  - Remove Turbolinks
  - Option to install the gem 'devise'
  - Option to install the gems 'cucumber-rails' and 'capybara'

Once these app-type dependent modifications are complete, the template will modify the following:

  - Create database.yml configured for postgresql
  - Create database.example.yml and secrets.example.yml
  - Create .rubocop.yml file for local linting
  - Create .travis.yml file correctly configured
  - Append .gitignore with secret_token.rb, secrets.yml and database.yml
  - Bundle install and installation of gem configs:
    * rspec
    * factory_girl_rails
    * database_cleaner
    * shoulda_matchers
    * codeclimate-test-reporter
    * taperole
  - Installation of optional gem configs:
    * smashing_docs
    * devise
    * devise_token_auth
    * cucumber-rails
    * capybara
  - Cleanup of auto-generated files that fail local linting
  - Remove test directory
  - Generate README.md
  - Create development and test databases
  - Initialize git  

## Gemfile

Boxcar contains application gems including:

* [Devise](https://github.com/plataformatec/devise) for authentication
* [Devise Token Auth](https://github.com/lynndylanhurley/devise_token_auth) for token-based authentication
* [Postgres](https://github.com/ged/ruby-pg) for access to the Postgres database
* [Unicorn](https://github.com/defunkt/unicorn) as the app server
* [Taperole](https://github.com/smashingboxes/taperole) for deployment

NOTE: For now, the template will only install and set up taperole if using Rails 4. When taperole is compatible with Rails 5, we will add this functionality back.

And development gems including:

* [Letter Opener](https://github.com/ryanb/letter_opener) to view emails in browser
* [Better Errors](https://github.com/charliesome/better_errors) to access an IRB console on exception pages
* [Spring](https://github.com/rails/spring) for fast Rails actions via pre-loading
* [Web Console](https://github.com/rails/web-console) for better debugging via in-browser IRB consoles

And testing gems including:

* [Awesome Print](https://github.com/michaeldv/awesome_print) to pretty print Ruby objects
* [Binding Pry](https://github.com/pry/pry) to stop execution and get a debugger console
* [Capybara](https://github.com/jnicklas/capybara) to simulate how a user interacts with the app
* [Code Climate Test Reporter](https://github.com/codeclimate/ruby-test-reporter) to integrate Code Climate and Travis
* [Cucumber Rails](https://github.com/cucumber/cucumber-rails) for automated feature tests
* [Database Cleaner](https://github.com/DatabaseCleaner/database_cleaner) for cleaning the database
* [Factory Girl](https://github.com/thoughtbot/factory_girl) for test data
* [RSpec Rails](https://github.com/rspec/rspec-rails) for unit testing
* [Rubocop](https://github.com/bbatsov/rubocop) for linting
* [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers) for common RSpec matchers
* [Smashing Docs](https://github.com/thoughtbot/shoulda-matchers) for API documentation
