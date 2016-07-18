require_relative 'lib/gem_configurator.rb'
require_relative 'lib/gemfile_configurator.rb'
require_relative 'lib/file_modifier.rb'
require_relative 'lib/database_generator.rb'
require_relative 'lib/installer.rb'
require_relative 'lib/git_initializer.rb'

# -----------------------------
# CREATE TEMPLATE
# -----------------------------
remove_gemfile
# -----------------------------
# API ONLY APP?
# -----------------------------
if yes?("Is this an API app? (y/n)")
  api_gemfile
  if yes?("Does this API app have an admin interface? (y/n)")
    api_with_admin_install
  else
    api_only_install
  end
else
  integrated_app_install
end
# -----------------------------
# DATABASE
# -----------------------------
database_set_up
travis_set_up
git_ignore_append
# -----------------------------
# GEM ADDITIONS (OPTIONAL)
# -----------------------------
add_gem_configs
install_optional_gems
# -----------------------------
# SETUP
# -----------------------------
rubocop_clean_up
remove_test_dir
generate_readme
create_database
initialize_git
# -----------------------------
# COMPLETE
# -----------------------------
puts "\nBoxcar template successfully created!"
