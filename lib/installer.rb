def api_only_install
  api_only_modifications
  devise_auth?
  smashing_docs?
end

def api_with_admin_install
  remove_turbolinks
  devise_auth?
  cucumber_capybara?
  smashing_docs?
end

def integrated_app_install
  integrated_app_gemfile
  remove_turbolinks
  devise?
  cucumber_capybara?
end
