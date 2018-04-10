module DeviseTokenAuthResponseSerializer
  def render_update_success
    render_serialized_resource
  end

  def render_create_success
    render_serialized_resource
  end

  private

  def render_serialized_resource
    render json: {
      status: "success",
      data: resource_data(
        resource_json: ActiveModelSerializers::SerializableResource.new(@resource).as_json
      )
    }
  end
end
