class Api::V1::Users::RegistrationsController < DeviseTokenAuth::RegistrationsController
  include DeviseTokenAuthResponseSerializer
  before_action :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: %i(email password password_confirmation)
    )
  end
end
