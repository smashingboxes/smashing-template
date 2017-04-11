require_relative './file_creator.rb'

def remove_gemfile
  remove_file "Gemfile"
end

def api_gemfile
  file "Gemfile", render_file(path("Gemfile_api_only"))
end

def integrated_app_gemfile
  file "Gemfile", render_file(path("Gemfile"))
end

def rails_4_gemfile
  gsub_file 'Gemfile', /'rails', '~> \d.*'/, "'rails', '~> #{Rails::VERSION::STRING}'"
  gsub_file 'Gemfile', /puma/i, 'unicorn'
  gsub_file 'Gemfile', /'taperole'.*/, "'taperole', '~> 1.8'"
end

def rails_4_app?
  Rails::VERSION::STRING.start_with?('4')
end
