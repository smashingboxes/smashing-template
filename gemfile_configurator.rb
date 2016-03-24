require_relative './file_creator.rb'

def remove_gemfile
  remove_file "Gemfile"
end

def api_gemfile
  file "Gemfile", render_file("#{$path}/files/Gemfile_api_only")
end

def integrated_app_gemfile
  file "Gemfile", render_file("#{$path}/files/Gemfile")
end
