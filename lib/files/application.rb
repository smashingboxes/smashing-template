class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  protect_from_forgery with: :exception

  private

  def render_success_json(data: {}, included: [], is_collection: false, message: "Success!")
    json = JSONAPI::Serializer.serialize(data, include: included, is_collection: is_collection)
    meta = {
      success: true,
      message: message
    }

    render json: json.merge(meta: meta), status: 200
  end

  def render_failure_json(status: nil, errors: [], message: "Failure.")
    meta = { success: false, message: message }
    render json: {
      meta: meta,
      errors: errors
    }, status: status
  end
end
