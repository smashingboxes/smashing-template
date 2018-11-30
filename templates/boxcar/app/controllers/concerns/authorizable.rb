module Authorizable
    include Pundit
    after_action :verify_authorized, except: :index, unless: :active_admin_controller?
    after_action :verify_policy_scoped, only: :index, unless: :active_admin_controller?

    rescue_from Pundit::NotAuthorizedError do
        render_failure_json(
            status: 403, 
            errors: ["Unauthorized."], 
            message: "Unauthorized.")
    end
end