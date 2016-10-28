class Api::AuthOverrides::RegistrationsController < DeviseTokenAuth::RegistrationsController
  def sign_up_params
    params.require(:data).require(:attributes).permit(
      :first_name,
      :last_name,
      :password,
      :email,
      :phone_number,
      :image,
      :is_incognito,
      :status
    )
  end

  def account_update_params
    params.require(:data).require(:attributes).permit(
      :first_name,
      :last_name,
      :password,
      :email,
      :phone_number,
      :image,
      :is_incognito,
      :status
    )
  end

  protected

  def render_create_success
    render_success_json(data: @resource)
  end

  def render_create_error
    errors = registrations_resource_errors
    render_failure_json(status: 422, errors: errors)
  end

  def render_destroy_success
    render_success_json(data: @resource)
  end

  def render_destroy_error
    errors = [JsonError.new(
      path: "/",
      detail: I18n.t("devise_token_auth.registrations.account_to_destroy_not_found")
    ).create_404]

    render_failure_json(status: 404, errors: errors)
  end

  def render_update_success
    render_success_json(data: @resource)
  end

  def render_update_error
    errors = registrations_resource_errors
    render_failure_json(status: 422, errors: errors.uniq)
  end

  def render_update_error_user_not_found
    errors = [JsonError.new(
      path: "/",
      detail: I18n.t("devise_token_auth.registrations.user_not_found")
    ).create_404]

    render_failure_json(status: 404, errors: errors)
  end

  private

  def registrations_resource_errors
    @resource.errors.map do |key, value|
      JsonError.new(
        pointer: key,
        detail: "#{key.to_s.capitalize} #{value}"
      ).create_422
    end
  end
end
