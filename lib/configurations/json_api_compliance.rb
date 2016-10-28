require_relative './controllers.rb'
require_relative '../content_editor'

class JsonApiCompliance
  def integrate
    override_devise_auth_controllers
    add_render_methods_to_application
    add_json_error_concern
  end

  private

  def override_devise_auth_controllers
    path = "app/controllers/api/auth_overrides"
    FileUtils.mkdir_p path
    override_controllers(path, [
      "passwords",
      "registrations",
      "sessions"
    ])
  end

  def add_render_methods_to_application
    path = "app/controllers"
    override_controllers(path, ["application"])
  end

  def override_controllers(path, controllers)
    Controllers.new(
      path: path,
      controllers: controllers
    ).override
  end

  def add_json_error_concern
    path = "app/controllers/concerns/json_error.rb"
    replace_content(path: path)
  end
end
