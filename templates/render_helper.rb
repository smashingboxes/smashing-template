module RenderHelper
  extend ActiveSupport::Concern

  def render_failure_json(status: nil, errors: [], message: "Failure.")
    render json: {
      meta: { success: false, message: message },
      errors: errors
    }, status: status
  end

  def render_success_json(data: {}, message: "Success!", serializer: nil)
    render_params = {
      json: data,
      meta: { success: true, message: message },
      status: 200,
      serializer_key(data) => serializer,
      include: "**"
    }
    render render_params.compact
  end

  def render_service(outcome: nil, serializer: nil, data: nil)
    if outcome.valid?
      render_service_success_json(outcome, serializer: serializer, data: data)
    else
      render_service_failure_json(outcome)
    end
  end

  def render_service_success_json(outcome, serializer: nil, data: nil)
    data ||= outcome.result
    message = outcome.success_message
    render_success_json(data: data, message: message, serializer: serializer)
  end

  def render_service_failure_json(outcome)
    errors = outcome.errors
    message = outcome.failure_message
    render_failure_json(
      status: outcome.failure_status || 422,
      errors: errors,
      message: message
    )
  end

  def render_save(object)
    if object.save
      render_success_json(data: object)
    else
      render_failure_json(
        errors: object.errors.as_json.merge(full_messages: object.errors.full_messages),
        status: 422
      )
    end
  end

  def render_access_denied
    render_failure_json(status: 401, errors: "Access denied")
  end

  def serialize(data)
    ActiveModelSerializers::SerializableResource.new(data)
  end

  private

  def serializer_key(data)
    data.is_a?(ActiveRecord::Base) ? :serializer : :each_serializer
  end
end
