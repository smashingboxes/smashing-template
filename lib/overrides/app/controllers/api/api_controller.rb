class Api::ApiController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def record_not_found
    errors = [JsonError.new(
      path: "/",
      detail: "This record could not be found"
    ).create_404]

    render_failure_json(status: 404, errors: errors)
  end

  private

  def authenticate_user!
    unless current_api_user
      errors = [JsonError.new(
        pointer: "",
        detail: "Authorized users only."
      ).create_401]

      render_failure_json(status: 401, errors: errors, message: "Authentication failed.")
    end
  end
end
