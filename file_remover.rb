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
