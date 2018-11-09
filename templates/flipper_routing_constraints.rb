# frozen_string_literal: true

class FlipperRoutingConstraints
  def self.matches?(request)
    Rails.logger.info "Warning: this is a default configuration for the FlipperUiConstraints."
    Rails.logger.info "Please modify this logic or delete this output according to your needs"
    current_user = request.env["warden"].user
    current_user&.admin?
  end
end