class Api::AuthOverrides::PasswordsController < DeviseTokenAuth::PasswordsController
  def edit
    @resource = resource_class.reset_password_by_token(
      reset_password_token: edit_params[:reset_password_token]
    )

    if @resource && @resource.id
      client_id  = SecureRandom.urlsafe_base64(nil, false)
      token      = SecureRandom.urlsafe_base64(nil, false)
      token_hash = BCrypt::Password.create(token)
      expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i # rubocop:disable Rails/TimeZone

      @resource.tokens[client_id] = {
        token:  token_hash,
        expiry: expiry
      }

      # ensure that user is confirmed
      @resource.skip_confirmation! if @resource.devise_modules.include?(:confirmable) && !@resource.confirmed_at # rubocop:disable Metrics/LineLength

      # allow user to change password once without current_password
      @resource.allow_password_change = true

      @resource.save!
      yield @resource if block_given?

      redirect_to(
        @resource.build_auth_url(
          params[:redirect_url],
          token: token,
          client_id: client_id,
          reset_password: true,
          config: params[:config]
        )
      )
    else
      render_edit_error
    end
  end

  protected

  def render_create_success
    message = I18n.t("devise_token_auth.passwords.sended", email: @email)
    render_success_json(data: @resource, message: message)
  end

  def render_create_error
    errors = @errors.map do |error|
      source = error.include?("password") ? "password" : "email"
      JsonError.new(
        pointer: source,
        detail: error
      ).create_404
    end

    render_failure_json(status: @error_status, errors: errors.uniq)
  end

  def render_create_error_missing_email
    errors = [JsonError.new(
      pointer: "email",
      detail: I18n.t("devise_token_auth.passwords.missing_email")
    ).create_401]

    render_failure_json(status: 401, errors: errors, message: "Authentication failed.")
  end

  def render_update_success
    message = I18n.t("devise_token_auth.passwords.successfully_updated")
    render_success_json(data: @resource, message: message)
  end

  def render_update_error_unauthorized
    errors = [JsonError.new(
      pointer: "password",
      detail: "Unauthorized. Try resending the forgot password email."
    ).create_401]

    render_failure_json(status: 401, errors: errors, message: "Authentication failed.")
  end

  def render_update_error_missing_password
    errors = [JsonError.new(
      pointer: "password",
      detail: I18n.t("devise_token_auth.passwords.missing_passwords")
    ).create_422]

    render_failure_json(status: 422, errors: errors)
  end

  def render_update_error
    errors = [JsonError.new(
      pointer: "password",
      detail: @resource.errors.full_messages.first
    ).create_422]

    render_failure_json(status: 422, errors: errors)
  end

  def render_edit_error
    redirect_to DeviseTokenAuth.default_password_reset_url
  end

  private

  def edit_params
    params.permit(:email, :password, :password_confirmation, :current_password, :reset_password_token) # rubocop:disable Metrics/LineLength
  end

  def resource_params
    params.require(:data).require(:attributes).permit(
      :email,
      :redirect_url
    )
  end

  def password_resource_params
    params.require(:data).require(:attributes).permit(
      :password,
      :password_confirmation
    )
  end
end
