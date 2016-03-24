require_relative './gem_configurator.rb'
require_relative './gemfile_configurator.rb'
require_relative './file_remover.rb'
require_relative './file_modifier.rb'
require_relative './database_setup.rb'
require_relative './installer.rb'
require_relative './initialize_git.rb'
require_relative './file_creator.rb'

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
smashing_docs?
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
remove_test_dir
generate_readme
create_database
initialize_git
# -----------------------------
# COMPLETE
# -----------------------------
puts "\nSmashing-Template successfully created!"
