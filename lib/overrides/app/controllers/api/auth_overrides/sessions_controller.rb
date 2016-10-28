class Api::AuthOverrides::SessionsController < DeviseTokenAuth::SessionsController
  protected

  def render_create_success
    render_success_json(data: @resource)
  end

  def render_create_error_not_confirmed
    errors = [JsonError.new(
      pointer: "email",
      detail: I18n.t(
        "devise_token_auth.sessions.not_confirmed",
        email: @resource.email
      )
    ).create_401]

    render_failure_json(status: 401, errors: errors, message: "Authentication failed.")
  end

  def render_create_error_bad_credentials
    errors = [JsonError.new(
      detail: I18n.t("devise_token_auth.sessions.bad_credentials")
    ).create_401]

    render_failure_json(status: 401, errors: errors, message: "Authentication failed.")
  end

  def render_destroy_success
    render_success_json(data: {}, is_collection: true)
  end

  def render_destroy_error
    errors = [JsonError.new(
      path: "/",
      detail: I18n.t("devise_token_auth.sessions.user_not_found")
    ).create_404]

    render_failure_json(status: 404, errors: errors)
  end

  private

  def resource_params
    params.require(:data).require(:attributes).permit(
      :password,
      :email
    )
  end
end
